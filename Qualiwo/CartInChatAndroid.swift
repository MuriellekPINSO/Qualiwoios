//
//  CartInChatAndroid.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 17/02/2026.
//

import SwiftUI

// MARK: - Cart In Chat View (Android Style)
struct CartInChatAndroidView: View {
    let cartItems: [CartItem]
    var onOrderRequest: () -> Void
    var onQuantityChange: (CartItem, Int) -> Void
    var onRemoveItem: (CartItem) -> Void
    var onClearCart: () -> Void
    @State private var isCreatingOrder = false
    @State private var showDeleteConfirm = false
    @State private var showClearCartConfirm = false
    @State private var itemToDelete: CartItem?
    @State private var isCollapsed = false
    
    var total: Double {
        cartItems.reduce(0) { $0 + (Double($1.quantity) * Double($1.product.price)) }
    }
    
    var totalArticles: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // Format number with space separator (e.g. 15 900)
    func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header with badge, title, total, trash, chevron
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                HStack(spacing: 10) {
                    // Cart icon with red badge
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.qOrange)
                        
                        // Badge count
                        Text("\(totalArticles)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mon panier")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(formatPrice(Int(total))) FCFA")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.qOrange)
                    }
                    
                    Spacer()
                    
                    if !isCollapsed {
                        // Trash icon
                        Button(action: { showClearCartConfirm = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Chevron
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            if !isCollapsed {
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                // MARK: - Cart items list
                VStack(spacing: 16) {
                    ForEach(cartItems) { item in
                        HStack(alignment: .top, spacing: 14) {
                            // Product thumbnail with white/light background
                            if let images = item.product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(12)
                                    case .empty, .failure:
                                        Color.qSurface
                                            .frame(width: 70, height: 70)
                                            .cornerRadius(12)
                                    @unknown default:
                                        Color.qSurface
                                            .frame(width: 70, height: 70)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Product info
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.product.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text("QUALIWO")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.qOrange)
                                    }
                                    
                                    Spacer()
                                    
                                    // X button to remove
                                    Button(action: {
                                        itemToDelete = item
                                        showDeleteConfirm = true
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer().frame(height: 4)
                                
                                // Price + Quantity controls row
                                HStack {
                                    Text("\(formatPrice(item.product.price)) FCFA")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Quantity controls capsule (- N +)
                                    HStack(spacing: 0) {
                                        Button(action: {
                                            onQuantityChange(item, item.quantity - 1)
                                        }) {
                                            Text("–")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 36, height: 34)
                                                .background(Color.gray.opacity(0.4))
                                                .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                                        }
                                        
                                        Text("\(item.quantity)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 32, height: 34)
                                            .background(Color.gray.opacity(0.25))
                                        
                                        Button(action: {
                                            onQuantityChange(item, item.quantity + 1)
                                        }) {
                                            Text("+")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 36, height: 34)
                                                .background(Color.qOrange)
                                                .cornerRadius(8, corners: [.topRight, .bottomRight])
                                        }
                                    }
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                // MARK: - Total line
                HStack {
                    Text("Total (\(totalArticles) article\(totalArticles > 1 ? "s" : ""))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(formatPrice(Int(total))) FCFA")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.qOrange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                // MARK: - "Passer commande" button
                Button(action: {
                    isCreatingOrder = true
                    onOrderRequest()
                }) {
                    if isCreatingOrder {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Création en cours...")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.qOrange.opacity(0.7))
                        .cornerRadius(12)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 16))
                            Text("Passer commande")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.qOrange)
                        .cornerRadius(12)
                    }
                }
                .disabled(isCreatingOrder)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.qCardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        .alert("Supprimer l'article", isPresented: $showDeleteConfirm) {
            Button("Non", role: .cancel) { }
            Button("Oui, supprimer", role: .destructive) {
                if let item = itemToDelete {
                    onRemoveItem(item)
                }
                itemToDelete = nil
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cet article du panier ?")
        }
        .alert("Vider le panier", isPresented: $showClearCartConfirm) {
            Button("Non", role: .cancel) { }
            Button("Oui, tout supprimer", role: .destructive) {
                onClearCart()
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer tous les articles du panier ?")
        }
    }
}
