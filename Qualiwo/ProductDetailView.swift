//
//  ProductDetailView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 10/02/2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductResult
    @State private var quantity = 0
    @State private var isLiked = false
    var onAddToCart: (ProductResult, Int) -> Void
    
    private var totalPrice: Int {
        quantity * product.price
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Product Image - white rounded container with X button
                        ZStack(alignment: .topTrailing) {
                            // White image container
                            VStack {
                                if let images = product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: 220)
                                        case .empty, .failure:
                                            ProgressView()
                                                .frame(height: 220)
                                        @unknown default:
                                            Color.clear
                                                .frame(height: 220)
                                        }
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .frame(height: 220)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // X button (top right on the image)
                            Button(action: {
                                onAddToCart(product, 0) // dismiss signal: 0 quantity
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(.top, 22)
                            .padding(.trailing, 26)
                        }
                        
                        // Product Info
                        VStack(alignment: .leading, spacing: 16) {
                            // Name
                            Text(product.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            // Price + Stock
                            HStack(alignment: .center) {
                                Text("\(product.price) XOF")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.qOrange)
                                
                                Spacer()
                                
                                if let stock = product.stock {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(stock.is_available ? Color.green : Color.red)
                                            .frame(width: 7, height: 7)
                                        
                                        Text("\(stock.quantity) \(stock.is_available ? "En stock" : "Rupture")")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(stock.is_available ? .green : .red)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(stock.is_available ? Color.green.opacity(0.4) : Color.red.opacity(0.4), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Quantity + Total
                            HStack {
                                HStack(spacing: 10) {
                                    Text("Quantité")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .layoutPriority(1)
                                    
                                    HStack(spacing: 0) {
                                        Button(action: { if quantity > 0 { quantity -= 1 } }) {
                                            Text("—")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(width: 36, height: 36)
                                                .background(Color.qOrange)
                                        }
                                        
                                        Text("\(quantity)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(Color.qSurfaceLight)
                                        
                                        Button(action: { quantity += 1 }) {
                                            Text("+")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(width: 36, height: 36)
                                                .background(Color.qOrange)
                                        }
                                    }
                                    .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    if quantity > 0 {
                                        Text("\(totalPrice) XOF")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("---")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    Text("TOTAL")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Description")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(product.description)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                
                // Add to cart button (fixed at bottom)
                Button(action: {
                    if quantity > 0 {
                        onAddToCart(product, quantity)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Ajouter au panier")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(quantity > 0 ? Color.qOrange : Color.qOrange.opacity(0.4))
                    .cornerRadius(14)
                }
                .disabled(quantity == 0)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .padding(.top, 6)
            }
            .background(Color.qCardBg)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: -5)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    let sampleProduct = ProductResult(
        id: "123",
        name: "Indomie Nouilles Instantanées Goût Poulet 120g",
        description: "Sachet de nouilles instantanées à la saveur de poulet pour une préparation rapide en quelques minutes. Ces pâtes alimentaires se présentent sous forme de bloc de vermicelles secs à réhydrater dans de l'eau bouillante. Ce produit est idéal pour un repas express, une soupe rapide ou une collation chaude. Le paquet contient les assaisonnements nécessaires pour obtenir un bouillon parfumé. Format généreux pour une personne.",
        price: 350,
        images: ["https://via.placeholder.com/300"],
        stock: ProductStock(status: "in_stock", quantity: 216, is_available: true),
        similarity_score: 0.95
    )
    
    ZStack {
        Color.qDarkBg.ignoresSafeArea()
        ProductDetailView(product: sampleProduct) { _, _ in }
    }
}
