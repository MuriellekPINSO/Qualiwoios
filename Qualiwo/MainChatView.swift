//
//  MainChatView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 05/02/2026.
//

import SwiftUI

// MARK: - API Response Models
struct APIMessage: Codable {
    let role: String
    let content: String
}

struct ChatResponse: Codable {
    let response: String
    let products: [ProductResult]?
    let messages: [APIMessage]?
}

struct ProductResult: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Int
    let images: [String]?
    let stock: ProductStock?
    let similarity_score: Double?
}

struct ProductStock: Codable {
    let status: String
    let quantity: Int
    let is_available: Bool
}

// MARK: - Chat Data Models
struct ChatConversation: Identifiable {
    let id = UUID()
    var title: String
    var lastMessage: String
    var time: String
    var messages: [ChatMessage]
}

enum ChatMessageType {
    case text
    case products
    case cart
    case order
}

struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var products: [ProductResult]? = nil
    var messageType: ChatMessageType = .text
    var cartItems: [CartItem]? = nil
    var order: Order? = nil
}

// MARK: - Main Chat View (home screen after login)
struct MainChatView: View {
    @State private var showSidebar = false
    @State private var messageInput = ""
    @State private var messages: [ChatMessage] = []
    @State private var selectedConversation: ChatConversation?
    @State private var isLoading = false
    @State private var cartItems: [CartItem] = []
    @State private var selectedProduct: ProductResult?
    @State private var showProductDetail = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { withAnimation(.easeInOut(duration: 0.25)) { showSidebar.toggle() } }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    
                    Spacer()
                    
                    Text("Qualiwo")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { 
                            // Scroll to cart in chat or show it
                            if !cartItems.isEmpty {
                                updateCartInChat()
                            }
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bag.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                                
                                if !cartItems.isEmpty {
                                    Text("\(cartItems.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                        
                        Circle()
                            .fill(Color.qGradientPrimary)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("U")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Content area
                if messages.isEmpty {
                    // Welcome state
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.qOrange)
                        
                        Text("Comment puis-je vous aider?")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                } else {
                    // Messages list
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message) { product in
                                        // Add to cart
                                        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
                                            cartItems[index].quantity += 1
                                        } else {
                                            cartItems.append(CartItem(product: product, quantity: 1))
                                        }
                                        // Show cart in chat after adding product
                                        updateCartInChat()
                                    } onProductSelect: { product in
                                        selectedProduct = product
                                        showProductDetail = true
                                    } onOrderRequest: { cartItemsToOrder in
                                        createOrderFromChat(cartItemsToOrder)
                                    } onQuantityChange: { item, newQuantity in
                                        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                                            if newQuantity > 0 {
                                                cartItems[index].quantity = newQuantity
                                            } else {
                                                cartItems.removeAll { $0.id == item.id }
                                            }
                                            updateCartInChat()
                                        }
                                    } onRemoveItem: { item in
                                        cartItems.removeAll { $0.id == item.id }
                                        updateCartInChat()
                                    } onClearCart: {
                                        cartItems.removeAll()
                                        updateCartInChat()
                                    }
                                    .id(message.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input bar
                HStack(spacing: 12) {
                    TextField("", text: $messageInput)
                        .foregroundColor(.white)
                        .disabled(isLoading)
                        .placeholder(when: messageInput.isEmpty) {
                            Text("Demander au Chat")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding(.vertical, 8)
                    
                    Button(action: { sendMessage() }) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.qGradientPrimary)
                                .clipShape(Circle())
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.qSurfaceLight)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // Sidebar overlay
            if showSidebar {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
                    }
                
                HStack(spacing: 0) {
                    SidebarView(
                        isLoggedIn: $isLoggedIn,
                        showSidebar: $showSidebar,
                        onSelectConversation: { conv in
                            selectedConversation = conv
                            messages = conv.messages
                            withAnimation { showSidebar = false }
                        },
                        onNewChat: {
                            messages = []
                            selectedConversation = nil
                            withAnimation { showSidebar = false }
                        }
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.82)
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSidebar)
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                ProductDetailView(product: product) { product, quantity in
                    // Add to cart with the specified quantity
                    if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
                        cartItems[index].quantity += quantity
                    } else {
                        cartItems.append(CartItem(product: product, quantity: quantity))
                    }
                    // Show cart in chat after adding product
                    updateCartInChat()
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMsg = ChatMessage(content: messageInput, isFromUser: true, timestamp: Date())
        messages.append(userMsg)
        let query = messageInput
        messageInput = ""
        isLoading = true
        
        // Call API
        Task {
            do {
                // Build messages array for API
                var apiMessages: [[String: String]] = []
                
                // Add all previous messages
                for msg in messages {
                    let role = msg.isFromUser ? "user" : "assistant"
                    apiMessages.append([
                        "role": role,
                        "content": msg.content
                    ])
                }
                
                let requestBody: [String: Any] = ["messages": apiMessages]
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
                
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/chat")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                let chatResponse = try decoder.decode(ChatResponse.self, from: data)
                
                // Clean response text if products are present
                var cleanedResponse = chatResponse.response
                if let products = chatResponse.products, !products.isEmpty {
                    cleanedResponse = cleanTextForProducts(cleanedResponse)
                }
                
                // Add bot response
                let botMsg = ChatMessage(
                    content: cleanedResponse,
                    isFromUser: false,
                    timestamp: Date(),
                    products: chatResponse.products
                )
                
                DispatchQueue.main.async {
                    messages.append(botMsg)
                    isLoading = false
                }
            } catch {
                print("API Error: \(error)")
                DispatchQueue.main.async {
                    let errorMsg = ChatMessage(
                        content: "Désolé, une erreur est survenue. Veuillez réessayer.",
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(errorMsg)
                    isLoading = false
                }
            }
        }
    }
    
    // Function to clean product list from response text
    private func cleanTextForProducts(_ text: String) -> String {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        // Remove lines that are likely product listings (starting with -, 1., 2., etc.)
        lines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Keep lines that don't look like list items
            if trimmed.isEmpty { return false }
            if trimmed.hasPrefix("-") && trimmed.count > 2 { return false }
            if trimmed.hasPrefix("*") && trimmed.count > 2 { return false }
            if let first = trimmed.first, first.isNumber {
                if trimmed.count > 2 && (trimmed[trimmed.index(trimmed.startIndex, offsetBy: 1)] == "." || 
                                         trimmed[trimmed.index(trimmed.startIndex, offsetBy: 1)] == ")") {
                    return false
                }
            }
            return true
        }
        
        let cleaned = lines.joined(separator: "\n").trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? "Voici les produits qui pourraient vous intéresser :" : cleaned
    }
    
    // Function to show cart in chat
    func showCartInChat() {
        guard !cartItems.isEmpty else { return }
        
        let cartMessage = ChatMessage(
            content: "",
            isFromUser: false,
            timestamp: Date(),
            messageType: .cart,
            cartItems: cartItems
        )
        
        messages.append(cartMessage)
    }
    
    // Function to update cart in chat (replace existing or add new)
    func updateCartInChat() {
        // If cart is empty, remove the cart message from chat
        if cartItems.isEmpty {
            messages.removeAll(where: { $0.messageType == .cart })
            return
        }
        
        // Check if there's already a cart message
        if let lastCartIndex = messages.lastIndex(where: { $0.messageType == .cart }) {
            // Update existing cart message
            messages[lastCartIndex] = ChatMessage(
                content: "",
                isFromUser: false,
                timestamp: Date(),
                messageType: .cart,
                cartItems: cartItems
            )
        } else {
            // Add new cart message
            let cartMessage = ChatMessage(
                content: "",
                isFromUser: false,
                timestamp: Date(),
                messageType: .cart,
                cartItems: cartItems
            )
            messages.append(cartMessage)
        }
    }
    
    // Function to show order in chat
    func showOrderInChat(_ order: Order) {
        let orderMessage = ChatMessage(
            content: "",
            isFromUser: false,
            timestamp: Date(),
            messageType: .order,
            order: order
        )
        
        messages.append(orderMessage)
    }
    
    // Function to create order from chat
    func createOrderFromChat(_ orderCartItems: [CartItem]) {
        let items = orderCartItems.map { item in
            [
                "product_id": item.product.id,
                "product_name": item.product.name,
                "quantity": item.quantity,
                "price": Double(item.product.price)
            ] as [String: Any]
        }
        
        let totalAmount = orderCartItems.reduce(0.0) { $0 + (Double($1.quantity) * Double($1.product.price)) }
        
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
                    showOrderInChat(orderResponse.order)
                    // Clear cart items
                    cartItems.removeAll()
                    // Remove cart message from chat
                    messages.removeAll(where: { $0.messageType == .cart })
                }
            } catch {
                print("Order creation error: \(error)")
            }
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    let onAddToCart: (ProductResult) -> Void
    let onProductSelect: (ProductResult) -> Void
    let onOrderRequest: ([CartItem]) -> Void
    let onQuantityChange: ((CartItem, Int) -> Void)
    let onRemoveItem: ((CartItem) -> Void)
    let onClearCart: (() -> Void)
    
    @State private var isCartExpanded = true
    
    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                if !message.isFromUser {
                    // Bot avatar
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Text message
                if !message.content.isEmpty {
                            Text(message.content)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.qSurfaceLight)
                                .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        
                        // Cart display in chat
                        if message.messageType == .cart, let messageCartItems = message.cartItems {
                            CartInChatAndroidView(
                                cartItems: messageCartItems,
                                onOrderRequest: {
                                    onOrderRequest(messageCartItems)
                                },
                                onQuantityChange: onQuantityChange,
                                onRemoveItem: onRemoveItem,
                                onClearCart: onClearCart
                            )
                        }
                        
                        // Order display in chat
                        if message.messageType == .order, let order = message.order {
                            OrderInChatAndroidView(order: order)
                        }
                        
                        // Products carousel for bot messages
                        if let products = message.products, !products.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(products) { product in
                                        ProductCardAndroid(
                                            product: product,
                                            onAddToCart: {
                                                onAddToCart(product)
                                            },
                                            onTap: {
                                                onProductSelect(product)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                            .frame(height: 350)
                        }
                    }
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.qGradientPrimary)
                        .cornerRadius(20, corners: [.topLeft, .topRight, .bottomLeft])
                        .shadow(color: Color.qOrange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            

        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: ProductResult
    let onAddToCart: () -> Void
    let onTap: () -> Void
    
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
                                    .frame(height: 180)
                                    .clipped()
                            case .empty, .failure:
                                Color.gray
                                    .frame(height: 180)
                                    .overlay(ProgressView())
                            @unknown default:
                                Color.gray
                                    .frame(height: 180)
                            }
                        }
                    } else {
                        Color.qCardBg
                            .frame(height: 180)
                    }
                    
                    // Gradient Overlay for text readability
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    
                    // Price badge
                    Text("\(product.price) FCFA")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(10)
                }
                
                // Product info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Add to cart button
                    Button(action: onAddToCart) {
                        HStack {
                            Image(systemName: "cart.fill.badge.plus")
                            Text("Ajouter")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.qGradientPrimary)
                        .cornerRadius(20)
                        .shadow(color: Color.qOrange.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(12)
            }
            .background(Color.qSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .frame(width: 220)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Cart Preview
struct CartPreview: View {
    @Binding var cartItems: [CartItem]
    @Binding var isLoading: Bool
    @Binding var isCollapsed: Bool
    @State private var isCreatingOrder = false
    @State private var createdOrder: Order?
    @State private var errorMessage: String?
    @State private var showOrderTracking = false
    var onOrderCreated: (Order) -> Void
    
    var total: Int {
        cartItems.reduce(0) { $0 + ($1.quantity * $1.product.price) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cart header (always visible and clickable)
            HStack(spacing: 12) {
                Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                    HStack(spacing: 12) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.qOrange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mon Panier")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if !isCollapsed {
                                Text("\(cartItems.count) article\(cartItems.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                
                Button(action: { withAnimation { cartItems.removeAll() } }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.qOrange)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            // Expandable content
            if !isCollapsed {
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Cart items list
                VStack(spacing: 10) {
                    ForEach($cartItems) { $item in
                        HStack(spacing: 10) {
                            // Product thumbnail
                            if let images = item.product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 45, height: 45)
                                            .cornerRadius(6)
                                    case .empty, .failure:
                                        Color.qCardBg
                                            .frame(width: 45, height: 45)
                                            .cornerRadius(6)
                                    @unknown default:
                                        Color.qCardBg
                                            .frame(width: 45, height: 45)
                                            .cornerRadius(6)
                                    }
                                }
                            } else {
                                Color.qCardBg
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(6)
                            }
                            
                            // Product info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.product.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text("\(item.product.price) FCFA")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Quantity and subtotal
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 6) {
                                    Button(action: {
                                        if item.quantity > 1 {
                                            item.quantity -= 1
                                        } else {
                                            cartItems.removeAll { $0.id == item.id }
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 24)
                                            .background(Color.qOrange)
                                            .cornerRadius(5)
                                    }
                                    
                                    Text("\(item.quantity)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Button(action: { item.quantity += 1 }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 24)
                                            .background(Color.qOrange)
                                            .cornerRadius(5)
                                    }
                                }
                                
                                Text("\(item.quantity * item.product.price) FCFA")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.qOrange)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.qCardBg)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Total and button
                VStack(spacing: 10) {
                    HStack {
                        Text("TOTAL")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(total) FCFA")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.qOrange)
                    }
                    
                    Button(action: { createOrder() }) {
                        if isCreatingOrder {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Passer la commande")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.qOrange)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isCreatingOrder || cartItems.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
        .background(Color.qCardBg)
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .sheet(isPresented: $showOrderTracking) {
            if let order = createdOrder {
                OrderTrackingView(order: order)
            }
        }
    }
    
    private func createOrder() {
        isCreatingOrder = true
        
        let orderItems = cartItems.map { item in
            return ["product_id": item.product.id, "quantity": item.quantity]
        }
        
        let requestBody: [String: Any] = [
            "items": orderItems,
            "user_id": "test_user"
        ]
        
        Task {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
                
                var request = URLRequest(url: URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/create")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, _) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                let orderResponse = try decoder.decode(OrderResponse.self, from: data)
                
                DispatchQueue.main.async {
                    createdOrder = orderResponse.order
                    onOrderCreated(orderResponse.order)
                    cartItems.removeAll()
                    isCreatingOrder = false
                }
            } catch {
                print("Order creation error: \(error)")
                DispatchQueue.main.async {
                    isCreatingOrder = false
                }
            }
        }
    }
}

// MARK: - Cart View Wrapper
struct CartViewWrapper: View {
    @Binding var cartItems: [CartItem]
    @Binding var isPresented: Bool
    
    var body: some View {
        CartView(cartItems: $cartItems, isPresented: $isPresented)
            .background(Color.qDarkBg)
    }
}

// MARK: - Cart In Chat View
struct CartInChatView: View {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.qOrange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mon Panier")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if !isCollapsed {
                                Text("\(cartItems.count) article\(cartItems.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                
                Button(action: { showClearCartConfirm = true }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            
            if !isCollapsed {
                VStack(spacing: 8) {
                    ForEach(cartItems) { item in
                        HStack(spacing: 10) {
                            // Product thumbnail
                            if let images = item.product.images, let firstImage = images.first, let url = URL(string: firstImage) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    case .empty, .failure:
                                        Color.qCardBg
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    @unknown default:
                                        Color.qCardBg
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                    .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("\(item.product.price) FCFA")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Quantity controls and price
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(item.product.price * item.quantity) FCFA")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.qOrange)
                            
                            HStack(spacing: 6) {
                                Button(action: {
                                    onQuantityChange(item, item.quantity - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.qOrange)
                                }
                                
                                Text("\(item.quantity)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 24)
                                
                                Button(action: {
                                    onQuantityChange(item, item.quantity + 1)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.qOrange)
                                }
                                
                                Button(action: {
                                    itemToDelete = item
                                    showDeleteConfirm = true
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.qCardBg.opacity(0.5))
                    .cornerRadius(8)
                }
            }
            
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Total section
                VStack(alignment: .leading, spacing: 8) {
                    Text("TOTAL")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(total)) FCFA")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.qOrange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                
                Button(action: {
                    isCreatingOrder = true
                    onOrderRequest()
                }) {
                    if isCreatingOrder {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Création en cours...")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.qOrange.opacity(0.7))
                        .cornerRadius(8)
                    } else {
                        Text("Passer la commande")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.qOrange)
                            .cornerRadius(8)
                    }
                }
                .disabled(isCreatingOrder)
            }
        }
        .padding(16)
        .background(Color.qCardBg)
        .cornerRadius(12)
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

// MARK: - Order In Chat View
struct OrderInChatView: View {
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
            VStack(alignment: .leading, spacing: 16) {
                // Success or Cancelled Message
                if currentStatus == "cancelled" {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Commande annulée")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Commande créée avec succès !")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // Order Card
                VStack(alignment: .leading, spacing: 12) {
                    // Header with title and status (clickable)
                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isCollapsed.toggle() } }) {
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
                            
                            Text(statusText)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(statusColor)
                                .cornerRadius(6)
                        }
                        .contentShape(Rectangle())
                    }
                    
                    if !isCollapsed {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Order Steps or Cancelled message
                        if currentStatus == "cancelled" {
                            HStack(spacing: 12) {
                                Image(systemName: "xmark.octagon.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Commande annulée")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Cette commande a été annulée et ne sera pas traitée")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 16)
                        } else {
                            // Order Steps
                            VStack(spacing: 16) {
                            // Step 1: En attente d'acceptation
                            // Active when pending, Completed when preparing+
                            OrderStepRow(
                                icon: "clock.fill",
                                title: "En attente d'acceptation",
                                subtitle: "Votre commande a été reçue",
                                isActive: currentStatus == "pending",
                                isCompleted: currentStatus == "preparing" || currentStatus == "ready" || currentStatus == "completed"
                            )
                            
                            // Step 2: Prêt à être récupéré
                            // Active when preparing, Completed when ready+
                            OrderStepRow(
                                icon: "package.fill",
                                title: "Prêt à être récupéré",
                                subtitle: "En préparation",
                                isActive: currentStatus == "preparing",
                                isCompleted: currentStatus == "ready" || currentStatus == "completed"
                            )
                            
                            // Step 3: Commande complétée
                            // Active when ready, Completed when completed
                            OrderStepRow(
                                icon: "checkmark.circle.fill",
                                title: "Commande complétée",
                                subtitle: "Dernière étape",
                                isActive: currentStatus == "ready",
                                isCompleted: currentStatus == "completed"
                            )
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Total and item count
                    HStack {
                        Text("Total: \(Int(order.total)) CFA")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
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
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: { 
                            if canCancel {
                                showCancelAlert = true
                            }
                        }) {
                            if isCancelling {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.5))
                                    .cornerRadius(8)
                            } else {
                                Text("Annuler")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(canCancel ? Color.red.opacity(0.8) : Color.gray.opacity(0.5))
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(!canCancel || isCancelling)
                    }
                    }
                }
                .padding(16)
                .background(Color.qCardBg)
                .cornerRadius(12)
                .opacity(currentStatus == "cancelled" ? 0.7 : 1.0)
            }
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
                // Refresh status every 30 seconds while view is visible
                while !isDismissed {
                    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    if !isDismissed && currentStatus != "completed" && currentStatus != "cancelled" {
                        refreshOrderStatus()
                    }
                }
            }
        }
    }
    
    // MARK: - Cancel Order Function
    private func cancelOrder() {
        isCancelling = true
        
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/\(order.id)/status")!
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let requestBody: [String: Any] = [
                    "status": "cancelled"
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode == 200 {
                    // Success - update UI
                    DispatchQueue.main.async {
                        currentStatus = "cancelled"
                        isCancelling = false
                    }
                } else if httpResponse.statusCode == 400 {
                    // Bad request - maybe order already completed
                    let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let message = errorResponse?["message"] as? String ?? "Cette commande ne peut pas être annulée"
                    
                    DispatchQueue.main.async {
                        errorMessage = message
                        showError = true
                        isCancelling = false
                    }
                } else if httpResponse.statusCode == 403 {
                    DispatchQueue.main.async {
                        errorMessage = "Vous n'avez pas la permission d'annuler cette commande"
                        showError = true
                        isCancelling = false
                    }
                } else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        errorMessage = "Commande introuvable"
                        showError = true
                        isCancelling = false
                    }
                } else {
                    throw URLError(.badServerResponse)
                }
                
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de l'annulation: \(error.localizedDescription)"
                    showError = true
                    isCancelling = false
                }
            }
        }
    }
    
    // MARK: - Refresh Order Status
    private func refreshOrderStatus() {
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/orders/\(order.id)")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    return
                }
                
                let decoder = JSONDecoder()
                let updatedOrder = try decoder.decode(Order.self, from: data)
                
                DispatchQueue.main.async {
                    if updatedOrder.status != currentStatus {
                        withAnimation {
                            currentStatus = updatedOrder.status
                        }
                    }
                }
                
            } catch {
                // Silently fail - this is just a background refresh
                print("Error refreshing order status: \(error)")
            }
        }
    }
}

// MARK: - Order Step Row
struct OrderStepRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isActive: Bool
    let isCompleted: Bool
    
    var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .qOrange
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var displayIcon: String {
        if isCompleted {
            return "checkmark.circle.fill"
        } else {
            return icon
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: displayIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive || isCompleted ? .bold : .regular)
                    .foregroundColor(isCompleted ? .green : .white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isCompleted ? .green.opacity(0.7) : .gray)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
            }
        }
    }
}

#Preview {
    MainChatView(isLoggedIn: .constant(true))
}
