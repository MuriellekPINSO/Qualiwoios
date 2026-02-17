//
//  ProductCardView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 17/02/2026.
//

import SwiftUI

// MARK: - Product Card (Android Style)
struct ProductCardAndroid: View {
    let product: ProductResult
    let onAddToCart: () -> Void
    let onTap: () -> Void
    @State private var addedToCart = false
    @State private var quantity: Int = 0
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Product image with price badge
                ZStack(alignment: .topLeading) {
                    if let images = product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipped()
                            case .empty:
                                Color.qCardBg
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        ProgressView()
                                            .tint(.qOrange)
                                    )
                            case .failure:
                                Color.qCardBg
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Color.qCardBg
                                    .frame(width: 200, height: 200)
                            }
                        }
                    } else {
                        Color.qCardBg
                            .frame(width: 200, height: 200)
                    }
                    
                    // Price badge (top-left, like Android)
                    Text("\(product.price) FCFA")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.65))
                        .cornerRadius(8)
                        .padding(10)
                }
                
                // Product info section
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer().frame(height: 4)
                    
                    // Add to cart button or quantity control
                    if addedToCart && quantity > 0 {
                        // Quantity controls (like Android)
                        HStack(spacing: 0) {
                            Button(action: {
                                if quantity > 0 {
                                    quantity -= 1
                                    if quantity == 0 {
                                        addedToCart = false
                                    }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 36)
                                    .background(Color.qOrange)
                                    .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                            }
                            
                            Text("\(quantity)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(Color.qSurface)
                            
                            Button(action: {
                                quantity += 1
                                onAddToCart()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 36)
                                    .background(Color.qOrange)
                                    .cornerRadius(8, corners: [.topRight, .bottomRight])
                            }
                        }
                    } else {
                        // Add to cart button (like Android)
                        Button(action: {
                            quantity = 1
                            addedToCart = true
                            onAddToCart()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 13))
                                Text("Ajouter au panier")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.qOrange)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(12)
            }
            .background(Color.qCardBg)
            .cornerRadius(16)
            .frame(width: 200)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
