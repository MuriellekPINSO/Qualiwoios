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
                            VStack(spacing: 8) {
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                Text("Commande créée avec succès !")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 16)
                        }
                        
                        // Order Tracking Card
                        VStack(spacing: 0) {
                            // Collapsible Header
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Suivi de Commande")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("N° \(order.order_number) • AUJOURD'HUI")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.qOrange)
                                    }
                                    
                                    if order.status == "cancelled" {
                                        Text("ANNULÉ")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if !isCollapsed {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                // Status Timeline
                                VStack(spacing: 16) {
                                    StatusStep(
                                        title: "En attente d'acceptation",
                                        subtitle: "Confirmée",
                                        isCompleted: statusIndex >= 0,
                                        isActive: statusIndex == 0,
                                        icon: "checkmark"
                                    )
                                    
                                    StatusStep(
                                        title: "En préparation",
                                        subtitle: "Confirmée",
                                        isCompleted: statusIndex >= 1,
                                        isActive: statusIndex == 1,
                                        icon: "hourglass"
                                    )
                                    
                                    StatusStep(
                                        title: "Prêt à être récupéré",
                                        subtitle: "En attente",
                                        isCompleted: statusIndex >= 2,
                                        isActive: statusIndex == 2,
                                        icon: "car"
                                    )
                                    
                                    StatusStep(
                                        title: "Commande complétée",
                                        subtitle: "En attente",
                                        isCompleted: statusIndex >= 3,
                                        isActive: statusIndex == 3,
                                        icon: "checkmark"
                                    )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                // Total and Item Count
                                HStack {
                                    Text("Total: \(Int(order.total)) CFA")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(itemCount) ART.")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.qOrange)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                
                                // Buttons
                                HStack(spacing: 12) {
                                    Button(action: { showCancelAlert = true }) {
                                        Text("Annuler")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(red: 0.55, green: 0.22, blue: 0.22))
                                            .cornerRadius(10)
                                    }
                                    .disabled(order.status == "completed" || order.status == "cancelled")
                                    .opacity(order.status == "completed" || order.status == "cancelled" ? 0.5 : 1)
                                    
                                    Button(action: { dismiss() }) {
                                        Text("Fermer")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.qOrange)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                        }
                        .background(Color.qCardBg)
                        .cornerRadius(14)
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
        HStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 48, height: 48)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    getIconImage()
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Text info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Timeline connector
            if !isActive {
                VStack(spacing: 0) {
                    Capsule()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 2, height: 20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func getIconImage() -> some View {
        switch icon {
        case "hourglass":
            Image(systemName: "hourglass")
        case "car":
            Image(systemName: "car.fill")
        default:
            Image(systemName: "clock.fill")
        }
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
