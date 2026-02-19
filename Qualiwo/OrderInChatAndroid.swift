//
//  OrderInChatAndroid.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 17/02/2026.
//

import SwiftUI

// MARK: - Order In Chat View (Android Style)
struct OrderInChatAndroidView: View {
    let order: Order
    var isPaid: Bool
    var onPayOrder: ((Order) -> Void)?
    @State private var showCancelAlert = false
    @State private var isDismissed = false
    @State private var currentStatus: String
    @State private var isCancelling = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isCollapsed = false
    
    init(order: Order, isPaid: Bool = false, onPayOrder: ((Order) -> Void)? = nil) {
        self.order = order
        self.isPaid = isPaid
        self.onPayOrder = onPayOrder
        self._currentStatus = State(initialValue: order.status)
    }
    
    var statusIndex: Int {
        let statuses = ["pending", "preparing", "ready", "completed"]
        return statuses.firstIndex(of: currentStatus) ?? 0
    }
    
    var statusText: String {
        switch currentStatus {
        case "pending": return "EN ATTENTE"
        case "preparing": return "EN PRÉPARATION"
        case "ready": return "PRÊT"
        case "completed": return "TERMINÉ"
        case "cancelled": return "ANNULÉ"
        default: return currentStatus.uppercased()
        }
    }
    
    var statusColor: Color {
        switch currentStatus {
        case "pending": return .qOrange
        case "preparing": return .blue
        case "ready": return .green
        case "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
    
    var canCancel: Bool {
        return currentStatus != "completed" && currentStatus != "cancelled"
    }
    
    // Format number with space separator (e.g. 2 500)
    func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    var body: some View {
        if !isDismissed {
            VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Header: "Suivi de Commande" + Status badge
                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Suivi de Commande")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("N° \(order.order_number) • Aujourd'hui")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Status badge
                            Text(statusText)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(statusColor)
                                .cornerRadius(6)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(16)
                    
                    if !isCollapsed {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        
                        // MARK: - Order Steps Timeline
                        VStack(spacing: 0) {
                            if currentStatus == "cancelled" {
                                // Cancelled state
                                AndroidOrderStep(
                                    icon: "clock.fill",
                                    title: "En attente d'acceptation",
                                    subtitle: "Commande acceptée",
                                    isCompleted: true,
                                    isActive: false,
                                    isCancelled: true,
                                    showLine: true,
                                    showPayButton: false,
                                    onPayTapped: nil
                                )
                                
                                AndroidOrderStep(
                                    icon: "shippingbox.fill",
                                    title: "Prêt à être récupéré",
                                    subtitle: "Passer récupérer votre sac",
                                    isCompleted: false,
                                    isActive: false,
                                    isCancelled: true,
                                    showLine: true,
                                    showPayButton: false,
                                    onPayTapped: nil
                                )
                                
                                AndroidOrderStep(
                                    icon: "checkmark.seal.fill",
                                    title: "Commande terminée",
                                    subtitle: "Dernière étape",
                                    isCompleted: false,
                                    isActive: false,
                                    isCancelled: true,
                                    showLine: false,
                                    showPayButton: false,
                                    onPayTapped: nil
                                )
                            } else {
                                // Active order steps
                                AndroidOrderStep(
                                    icon: "clock.fill",
                                    title: "En attente d'acceptation",
                                    subtitle: statusIndex >= 1 ? "Votre commande est acceptée" : "Votre commande a été reçue",
                                    isCompleted: statusIndex >= 1,
                                    isActive: currentStatus == "pending",
                                    isCancelled: false,
                                    showLine: true,
                                    showPayButton: false,
                                    onPayTapped: nil
                                )
                                
                                AndroidOrderStep(
                                    icon: "shippingbox.fill",
                                    title: "Prêt à être récupéré",
                                    subtitle: "Passer récupérer votre sac",
                                    isCompleted: statusIndex >= 2,
                                    isActive: currentStatus == "preparing",
                                    isCancelled: false,
                                    showLine: true,
                                    showPayButton: !isPaid && (currentStatus == "ready" || statusIndex >= 2),
                                    onPayTapped: {
                                        onPayOrder?(order)
                                    }
                                )
                                
                                AndroidOrderStep(
                                    icon: "checkmark.seal.fill",
                                    title: "Commande terminée",
                                    subtitle: "Dernière étape",
                                    isCompleted: statusIndex >= 3,
                                    isActive: currentStatus == "ready",
                                    isCancelled: false,
                                    showLine: false,
                                    showPayButton: false,
                                    onPayTapped: nil
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        
                        // MARK: - Total
                        HStack {
                            Text("Total: \(formatPrice(Int(order.total))) CFA")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        // MARK: - Cancel button
                        Button(action: {
                            if canCancel {
                                showCancelAlert = true
                            }
                        }) {
                            if isCancelling {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.6))
                                    .cornerRadius(12)
                            } else {
                                Text(currentStatus == "cancelled" ? "Commande annulée" : "Annuler")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(currentStatus == "cancelled" ? .red : (canCancel ? .white : .gray))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(currentStatus == "cancelled" ? Color.red.opacity(0.15) : (canCancel ? Color(red: 0.35, green: 0.12, blue: 0.12) : Color.gray.opacity(0.3)))
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(!canCancel || isCancelling)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color.qCardBg)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                .opacity(currentStatus == "cancelled" ? 0.8 : 1.0)
            .alert("Annuler la commande", isPresented: $showCancelAlert) {
                Button("Non", role: .cancel) { }
                Button("Oui, annuler", role: .destructive) {
                    cancelOrder()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir annuler cette commande ?")
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue")
            }
            .task {
                while !isDismissed {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    if !isDismissed && currentStatus != "completed" && currentStatus != "cancelled" {
                        refreshOrderStatus()
                    }
                }
            }
        }
    }
    
    private func cancelOrder() {
        isCancelling = true
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/\(order.id)/status")!
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let requestBody: [String: Any] = ["status": "cancelled"]
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        currentStatus = "cancelled"
                        isCancelling = false
                    }
                } else {
                    let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let message = errorResponse?["message"] as? String ?? "Impossible d'annuler"
                    DispatchQueue.main.async {
                        errorMessage = message
                        showError = true
                        isCancelling = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    showError = true
                    isCancelling = false
                }
            }
        }
    }
    
    private func refreshOrderStatus() {
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/\(order.id)")!
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
                let updatedOrder = try JSONDecoder().decode(Order.self, from: data)
                DispatchQueue.main.async {
                    if updatedOrder.status != currentStatus {
                        withAnimation { currentStatus = updatedOrder.status }
                    }
                }
            } catch {
                print("Refresh error: \(error)")
            }
        }
    }
}

// MARK: - Android Order Step (Timeline Style)
struct AndroidOrderStep: View {
    let icon: String
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isActive: Bool
    let isCancelled: Bool
    let showLine: Bool
    let showPayButton: Bool
    let onPayTapped: (() -> Void)?
    
    var circleColor: Color {
        if isCancelled && !isCompleted { return Color.gray.opacity(0.3) }
        if isCompleted { return .green }
        if isActive { return .qOrange }
        return Color.gray.opacity(0.3)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline circle + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(circleColor.opacity(isCompleted || isActive ? 0.2 : 0.1))
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else if isActive {
                        Circle()
                            .stroke(Color.qOrange, lineWidth: 2.5)
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.qOrange)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                if showLine {
                    Rectangle()
                        .fill(isCompleted ? Color.green.opacity(0.5) : Color.gray.opacity(0.15))
                        .frame(width: 2, height: showPayButton ? 50 : 28)
                }
            }
            
            // Text + Pay button
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive || isCompleted ? .bold : .medium)
                    .foregroundColor(isActive || isCompleted ? .white : .gray)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isCompleted ? .green : isActive ? .qOrange : .gray)
                
                // Pay button (shown when status is "ready")
                if showPayButton && !isCancelled {
                    Button(action: {
                        onPayTapped?()
                    }) {
                        HStack(spacing: 8) {
                            Text("Payer ma commande")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Image(systemName: "hand.wave.fill")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.qOrange)
                        .cornerRadius(20)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, showLine ? 12 : 0)
            
            Spacer()
        }
    }
}
