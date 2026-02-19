//
//  OrderTrackingView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 10/02/2026.
//

import SwiftUI

// MARK: - Order Models
struct Order: Codable, Identifiable {
    let id: String
    let order_number: String
    let total: Double
    let status: String
    let created_at: String
    let last_updated_at: String
    let items: [OrderItem]?
    
    enum CodingKeys: String, CodingKey {
        case id, order_number, total, status, created_at, last_updated_at, items
    }
}

struct OrderItem: Codable, Identifiable {
    let id: String?
    let product_id: String
    let quantity: Int
    let price: Double
    let products: ProductInfo?
    
    enum CodingKeys: String, CodingKey {
        case id, product_id, quantity, price, products
    }
}

struct ProductInfo: Codable {
    let name: String
}

struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else {
            try container.encodeNil()
        }
    }
}

// MARK: - Order Tracking View
struct OrderTrackingView: View {
    let order: Order
    @State private var showCancelAlert = false
    @State private var isCancelling = false
    @State private var isCollapsed = false
    @Environment(\.dismiss) var dismiss
    
    var statusIndex: Int {
        let statuses = ["pending", "preparing", "ready", "completed"]
        return statuses.firstIndex(of: order.status) ?? 0
    }
    
    var itemCount: Int {
        order.items?.count ?? 0
    }
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Success Message (only show when expanded)
                        if !isCollapsed {
                            HStack(spacing: 12) {
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.qOrange.opacity(0.5), radius: 8, x: 0, y: 0)
                                
                                Text("Commande créée avec succès !")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(Color.qSurfaceLight)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                        }
                        
                        // Order Tracking Card
                        VStack(spacing: 0) {
                            // Collapsible Header
                            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Suivi de Commande")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        HStack(spacing: 8) {
                                            Text("N° \(order.order_number) • Aujourd'hui")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        if order.status == "cancelled" {
                                            Text("ANNULÉ")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                        }
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.gray)
                                            .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                                    }
                                }
                                .padding(20)
                                .background(Color.qSurface)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if !isCollapsed {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                // Status Timeline
                                VStack(spacing: 0) {
                                    StatusStep(
                                        title: "En attente d'acceptation",
                                        subtitle: statusIndex >= 1 ? "Votre commande est acceptée" : "Votre commande a été reçue",
                                        isCompleted: statusIndex >= 1,
                                        isActive: statusIndex == 0,
                                        icon: "clock.fill",
                                        showLine: true
                                    )
                                    
                                    StatusStep(
                                        title: "Prêt à être récupéré",
                                        subtitle: "Passer récupérer votre sac",
                                        isCompleted: statusIndex >= 2,
                                        isActive: statusIndex == 1,
                                        icon: "shippingbox.fill",
                                        showLine: true
                                    )
                                    
                                    StatusStep(
                                        title: "Commande terminée",
                                        subtitle: "Dernière étape",
                                        isCompleted: statusIndex >= 3,
                                        isActive: statusIndex == 2,
                                        icon: "checkmark.seal.fill",
                                        showLine: false
                                    )
                                }
                                .padding(20)
                                .background(Color.qSurface)
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                // Total and Item Count
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TOTAL")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                            .tracking(1)
                                            
                                        Text("\(Int(order.total)) CFA")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.qOrange)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(itemCount) articles")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                .padding(20)
                                .background(Color.qSurface)
                                
                                // Buttons
                                HStack(spacing: 12) {
                                    Button(action: { showCancelAlert = true }) {
                                        Text("Annuler la commande")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color(red: 0.3, green: 0.1, blue: 0.1))
                                            .cornerRadius(12)
                                    }
                                    .disabled(order.status == "completed" || order.status == "cancelled")
                                    .opacity(order.status == "completed" || order.status == "cancelled" ? 0.5 : 1)
                                    
                                    Button(action: { dismiss() }) {
                                        Text("Fermer")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .background(Color.qSurface)
                            }
                        }
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 16)
                        
                        // Items List (only show when expanded)
                        if !isCollapsed, let items = order.items, !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Articles commandés")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                
                                ForEach(items) { item in
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.products?.name ?? "Produit")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                            Text("Qty: \(item.quantity)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(Int(item.price)) CFA")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.qOrange)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.qInputBg)
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .alert("Annuler la commande", isPresented: $showCancelAlert) {
            Button("Annuler la commande", role: .destructive) {
                cancelOrder()
            }
            Button("Continuer", role: .cancel) { }
        } message: {
            Text("Êtes-vous sûr de vouloir annuler cette commande ?")
        }
    }
    
    private func cancelOrder() {
        isCancelling = true
        
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/\(order.id)/cancel")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let (_, _) = try await URLSession.shared.data(for: request)
                
                DispatchQueue.main.async {
                    isCancelling = false
                    dismiss()
                }
            } catch {
                print("Erreur annulation:", error)
                isCancelling = false
            }
        }
    }
}

// MARK: - Status Step Component
struct StatusStep: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isActive: Bool
    let icon: String
    let showLine: Bool
    
    var statusColor: Color {
        if isCompleted {
            return Color.green
        } else if isActive {
            return Color.qOrange
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon circle and line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    } else if isActive {
                        getIconImage()
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.qOrange)
                    } else {
                        getIconImage()
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    if isActive {
                        Circle()
                            .stroke(Color.qOrange, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                }
                
                if showLine {
                    Rectangle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 2, height: 30)
                }
            }
            
            // Text info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive || isCompleted ? .bold : .medium)
                    .foregroundColor(isActive || isCompleted ? .white : .gray)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                if isActive {
                    Text("En cours...")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.qOrange)
                        .padding(.top, 2)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, showLine ? 20 : 0)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func getIconImage() -> some View {
        Image(systemName: icon)
    }
}

#Preview {
    let sampleOrder = Order(
        id: "test-123",
        order_number: "BSS-20260210-001",
        total: 1700,
        status: "pending",
        created_at: "2025-02-10T10:30:00Z",
        last_updated_at: "2025-02-10T10:30:00Z",
        items: [
            OrderItem(
                id: "item-1",
                product_id: "prod-123",
                quantity: 1,
                price: 1700,
                products: ProductInfo(name: "Riz Parfumé 5kg")
            )
        ]
    )
    
    OrderTrackingView(order: sampleOrder)
}
