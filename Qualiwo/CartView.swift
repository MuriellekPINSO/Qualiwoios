//
//  CartView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 10/02/2026.
//

import SwiftUI

// MARK: - Cart Item Model
struct CartItem: Identifiable {
    let id = UUID()
    let product: ProductResult
    var quantity: Int
}

// MARK: - Cart View
struct CartView: View {
    @Binding var cartItems: [CartItem]
    @Binding var isPresented: Bool
    @State private var isCreatingOrder = false
    @State private var createdOrder: Order?
    @State private var showOrderTracking = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var total: Double {
        cartItems.reduce(0) { $0 + (Double($1.quantity) * Double($1.product.price)) }
    }
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Panier")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(cartItems.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.qOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if cartItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.qOrange)
                        
                        Text("Votre panier est vide")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Ajoutez des produits pour commencer")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Cart Items
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    onQuantityChange: { newQty in
                                        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                                            if newQty > 0 {
                                                cartItems[index].quantity = newQty
                                            } else {
                                                cartItems.remove(at: index)
                                            }
                                        }
                                    },
                                    onRemove: {
                                        cartItems.removeAll { $0.id == item.id }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Total and Checkout
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(Int(total)) CFA")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.qOrange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Button(action: { createOrder() }) {
                            if isCreatingOrder {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Confirmer la commande")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isCreatingOrder || cartItems.isEmpty)
                        .padding(.vertical, 14)
                        .background(Color.qOrange)
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(Color.qCardBg)
                }
            }
        }
        .sheet(isPresented: $showOrderTracking) {
            if let order = createdOrder {
                OrderTrackingView(order: order)
            }
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Une erreur est survenue")
        }
    }
    
    private func createOrder() {
        isCreatingOrder = true
        
        let items = cartItems.map { item in
            [
                "product_id": item.product.id,
                "product_name": item.product.name,
                "quantity": item.quantity,
                "price": Double(item.product.price)
            ] as [String: Any]
        }
        
        let totalAmount = total
        
        let requestBody: [String: Any] = [
            "cart_items": items,
            "total_amount": totalAmount
        ]
        
        Task {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
                
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/create")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                let orderResponse = try decoder.decode(OrderResponse.self, from: data)
                
                DispatchQueue.main.async {
                    createdOrder = orderResponse.order
                    cartItems = [] // Clear cart
                    isCreatingOrder = false
                    showOrderTracking = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de la création de la commande: \(error.localizedDescription)"
                    showError = true
                    isCreatingOrder = false
                }
            }
        }
    }
    
    func addProduct(_ product: ProductResult) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImage(url: URL(string: item.product.images?.first ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                case .empty, .failure:
                    Color.qCardBg
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                @unknown default:
                    Color.qCardBg
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("\(item.product.price) CFA")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.qOrange)
                
                // Quantity Controls
                HStack(spacing: 8) {
                    Button(action: { onQuantityChange(item.quantity - 1) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.qOrange)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(minWidth: 30, alignment: .center)
                    
                    Button(action: { onQuantityChange(item.quantity + 1) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.qOrange)
                    }
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.qCardBg)
        .cornerRadius(8)
    }
}

// MARK: - Order Response
struct OrderResponse: Codable {
    let success: Bool
    let order_id: String
    let order_number: String
    let order: Order
    let items: [OrderItem]?
    let message: String
}

#Preview {
    CartView(cartItems: .constant([]), isPresented: .constant(true))
}
