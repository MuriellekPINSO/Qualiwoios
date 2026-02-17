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
    @State private var showCancelAlert = false
    @State private var isDismissed = false
    @State private var currentStatus: String
    @State private var isCancelling = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isCollapsed = false
    
    init(order: Order) {
        self.order = order
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
    
    var body: some View {
        if !isDismissed {
            VStack(alignment: .leading, spacing: 0) {
                // Header: "Suivi de Commande" + Status badge (Android style)
                Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suivi de Commande")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 6) {
                                Text("N° \(order.order_number)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("AUJOURD'HUI")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Status badge (Android style)
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
                    
                    if currentStatus == "cancelled" {
                        // Cancelled state - show all steps with cancelled style
                        VStack(spacing: 0) {
                            AndroidOrderStep(
                                icon: "clock.fill",
                                title: "En attente d'acceptation",
                                subtitle: "Commande acceptée",
                                isCompleted: true,
                                isActive: false,
                                isCancelled: true,
                                showLine: true
                            )
                            
                            AndroidOrderStep(
                                icon: "shippingbox.fill",
                                title: "Prêt à être récupéré",
                                subtitle: "En préparation",
                                isCompleted: false,
                                isActive: false,
                                isCancelled: true,
                                showLine: true
                            )
                            
                            AndroidOrderStep(
                                icon: "checkmark.seal.fill",
                                title: "Commande complétée",
                                subtitle: "Dernière étape",
                                isCompleted: false,
                                isActive: false,
                                isCancelled: true,
                                showLine: false
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    } else {
                        // Active order steps (Android style timeline)
                        VStack(spacing: 0) {
                            AndroidOrderStep(
                                icon: "clock.fill",
                                title: "En attente d'acceptation",
                                subtitle: statusIndex >= 1 ? "Commande acceptée" : "Votre commande a été reçue",
                                isCompleted: statusIndex >= 1,
                                isActive: currentStatus == "pending",
                                isCancelled: false,
                                showLine: true
                            )
                            
                            AndroidOrderStep(
                                icon: "shippingbox.fill",
                                title: "Prêt à être récupéré",
                                subtitle: "En préparation",
                                isCompleted: statusIndex >= 2,
                                isActive: currentStatus == "preparing",
                                isCancelled: false,
                                showLine: true
                            )
                            
                            AndroidOrderStep(
                                icon: "checkmark.seal.fill",
                                title: "Commande complétée",
                                subtitle: "Dernière étape",
                                isCompleted: statusIndex >= 3,
                                isActive: currentStatus == "ready",
                                isCancelled: false,
                                showLine: false
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.2))
                    
                    // Total + Article count (Android style)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total: \(Int(order.total)) CFA")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if let items = order.items {
                            Text("\(items.count) ART.")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.qOrange)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    // Cancel button (Android style - full width red)
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
                            Text("Annuler")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(canCancel ? Color(red: 0.95, green: 0.85, blue: 0.2) : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(canCancel ? Color(red: 0.35, green: 0.12, blue: 0.12) : Color.gray.opacity(0.3))
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
                        .frame(width: 2, height: 28)
                }
            }
            
            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive || isCompleted ? .bold : .medium)
                    .foregroundColor(isActive || isCompleted ? .white : .gray)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isCompleted ? .green : isActive ? .qOrange : .gray)
            }
            .padding(.top, 8)
            .padding(.bottom, showLine ? 12 : 0)
            
            Spacer()
        }
    }
}
