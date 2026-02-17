//
//  ProductDetailView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 10/02/2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductResult
    @State private var quantity = 1
    @State private var isLiked = false
    @Environment(\.dismiss) var dismiss
    var onAddToCart: (ProductResult, Int) -> Void
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Détails Produit")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { withAnimation { isLiked.toggle() } }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Product Image
                        if let images = product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 400)
                                        .cornerRadius(20)
                                        .padding(.horizontal, 16)
                                case .empty, .failure:
                                    Color.qCardBg
                                        .frame(height: 400)
                                        .cornerRadius(20)
                                        .overlay(ProgressView())
                                        .padding(.horizontal, 16)
                                @unknown default:
                                    Color.qCardBg
                                        .frame(height: 400)
                                        .cornerRadius(20)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Product name and price
                            VStack(alignment: .leading, spacing: 8) {
                                Text(product.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(product.price) FCFA")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.qOrange)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Description section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DESCRIPTION")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(1.2)
                                
                                Text(product.description)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineSpacing(2)
                            }
                            
                            // Stock info if available
                            if let stock = product.stock {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Disponibilité")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(stock.is_available ? Color.green : Color.red)
                                                .frame(width: 8, height: 8)
                                            
                                            Text(stock.is_available ? "En stock" : "Rupture")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(stock.is_available ? .green : .red)
                                        }
                                    }
                                    
                                    Text("\(stock.quantity) disponible\(stock.quantity > 1 ? "s" : "")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.qCardBg)
                                .cornerRadius(10)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Quantity selector
                            VStack(alignment: .leading, spacing: 12) {
                                Text("QUANTITÉ")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(1.2)
                                
                                HStack(spacing: 12) {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                            .background(Color.qOrange)
                                            .cornerRadius(12)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(quantity)")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                    
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                            .background(Color.qOrange)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Add to cart button
                            Button(action: {
                                onAddToCart(product, quantity)
                                dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bag.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Ajouter au panier")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.qOrange)
                                .cornerRadius(14)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleProduct = ProductResult(
        id: "123",
        name: "Nouilles aux œufs",
        description: "Nouilles sèches aux œufs présentées sous forme de longs filaments fins et légèrement ondulés.",
        price: 850,
        images: ["https://via.placeholder.com/300"],
        stock: ProductStock(status: "in_stock", quantity: 45, is_available: true),
        similarity_score: 0.95
    )
    
    ProductDetailView(product: sampleProduct) { _, _ in }
}
