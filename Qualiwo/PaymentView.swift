//
//  PaymentView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 19/02/2026.
//

import SwiftUI
import SafariServices
import WebKit

// MARK: - Payment Step
enum PaymentStep: Equatable {
    case methodSelection
    case mobileMoney
    case success
}

// MARK: - Payment Sheet View (popup dialog style like Android)
struct PaymentSheetView: View {
    let order: Order
    let onDismiss: () -> Void
    let onPaymentComplete: () -> Void
    
    @State private var currentStep: PaymentStep = .methodSelection
    @State private var selectedMethod: String = ""
    
    var totalAmount: Int { Int(order.total) }
    
    // Format number with space separator (e.g. 1 500)
    func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Group {
                switch currentStep {
                case .methodSelection:
                    paymentMethodCard
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                case .mobileMoney:
                    mobileMoneyCard
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    
                case .success:
                    successCard
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            
            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Method Selection Card
    private var paymentMethodCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Validation de la commande")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Total à régler : \(formatPrice(totalAmount)) FCFA")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(20)
            
            // Section title
            Text("MOYEN DE PAIEMENT")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .tracking(1)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Pay at counter
            Button(action: {
                selectedMethod = "counter"
                currentStep = .success
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.1, green: 0.3, blue: 0.3))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.6))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Payer au comptoir")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Je règle ma commande maintenant")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color.qSurfaceLight)
                .cornerRadius(14)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            // Mobile Money
            Button(action: {
                selectedMethod = "mobileMoney"
                currentStep = .mobileMoney
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mobile Money")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Orange Money, MTN, Wave")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color.qSurfaceLight)
                .cornerRadius(14)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Cancel button
            Button(action: onDismiss) {
                Text("Annuler")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.qOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.qOrange.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.qCardBg)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: -5)
    }
    
    // MARK: - Mobile Money Card
    private var mobileMoneyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Validation de la commande")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Total à régler : \(formatPrice(totalAmount)) FCFA")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(20)
            
            // Back button
            Button(action: {
                currentStep = .methodSelection
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Retour")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Phone icon + title
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.qSurfaceLight)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.qOrange)
                }
                
                Text("Paiement Mobile")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Finalisez votre commande en toute\nsécurité via mobile money.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
            MobileMoneyFormFields(
                totalAmount: totalAmount,
                orderId: order.id,
                formatPrice: formatPrice,
                onSuccess: {
                    currentStep = .success
                },
                onDismiss: onDismiss
            )
        }
        .background(Color.qCardBg)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: -5)
    }
    
    // MARK: - Success Card
    private var successCard: some View {
        VStack(spacing: 0) {
            // Close
            HStack {
                Spacer()
                Button(action: {
                    onPaymentComplete()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(20)
            
            VStack(spacing: 20) {
                // Big checkmark
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.green.opacity(0.4), radius: 15, x: 0, y: 5)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if selectedMethod == "counter" {
                    Text("Commande Confirmée !")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Votre commande est validée. Vous pourrez\nrégler au comptoir lors du retrait.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else {
                    Text("Paiement Réussi !")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Merci pour votre commande.\nVotre paiement a bien été reçu.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 24)
            
            // Button
            Button(action: {
                onPaymentComplete()
                onDismiss()
            }) {
                Text("Passer au retrait")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.qCardBg)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: -5)
    }
}

// MARK: - FedaPay Payment Response
struct PaymentCreateResponse: Codable {
    let payment_token: String
    let transaction_id: Int
    let checkout_url: String
}

struct PaymentStatusResponse: Codable {
    let id: Int
    let status: String
    let amount: Int?
    let mode: String?
    let reference: String?
    let customer: String?
}

// MARK: - Mobile Money Form Fields (inside the card)
struct MobileMoneyFormFields: View {
    let totalAmount: Int
    let orderId: String
    let formatPrice: (Int) -> String
    let onSuccess: () -> Void
    let onDismiss: () -> Void
    
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var isProcessing: Bool = false
    @State private var hasAttempted: Bool = false
    @State private var errorMessage: String? = nil
    @State private var transactionId: Int? = nil
    @State private var isWaitingForPayment: Bool = false
    @State private var showSafari: Bool = false
    @State private var checkoutURL: URL? = nil
    
    private var isPhoneValid: Bool {
        let digits = phoneNumber.replacingOccurrences(of: " ", with: "")
        return digits.count == 10 && digits.allSatisfy({ $0.isNumber })
    }
    
    private var isNameValid: Bool {
        return fullName.trimmingCharacters(in: .whitespaces).count >= 3
    }
    
    private var isFormValid: Bool {
        return isPhoneValid && isNameValid
    }
    
    /// Split "Jean Dupont" into ("Jean", "Dupont")
    private var nameParts: (firstname: String, lastname: String) {
        let parts = fullName.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1).map(String.init)
        let first = parts.first ?? fullName
        let last = parts.count > 1 ? parts[1] : ""
        return (first, last)
    }
    
    /// Format phone to international +229 format
    private var formattedPhone: String {
        let digits = phoneNumber.replacingOccurrences(of: " ", with: "")
        if digits.hasPrefix("+") { return digits }
        return "+229\(digits)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Full name
            VStack(alignment: .leading, spacing: 8) {
                Text("NOM COMPLET")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .tracking(1)
                
                TextField("", text: $fullName)
                    .foregroundColor(.white)
                    .placeholder(when: fullName.isEmpty) {
                        Text("Ex: Jean Kouassi")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.qSurfaceLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasAttempted && !isNameValid ? Color.red.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
                
                if hasAttempted && !isNameValid {
                    Text("Le nom doit contenir au moins 3 caractères")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            
            // Phone number
            VStack(alignment: .leading, spacing: 8) {
                Text("NUMÉRO DE TÉLÉPHONE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .tracking(1)
                
                TextField("", text: $phoneNumber)
                    .foregroundColor(.white)
                    .keyboardType(.phonePad)
                    .placeholder(when: phoneNumber.isEmpty) {
                        Text("Ex: 07 07 07 07 07")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.qSurfaceLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasAttempted && !isPhoneValid ? Color.red.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
                
                if hasAttempted && !isPhoneValid {
                    Text("Le numéro doit contenir 10 chiffres")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            
            // Error message
            if let error = errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 4)
            }
            
            // Waiting for payment message
            if isWaitingForPayment {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.qOrange)
                        .scaleEffect(0.7)
                    Text("En attente de confirmation du paiement…")
                        .font(.caption)
                        .foregroundColor(.qOrange)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 20)
        
        Spacer().frame(height: 20)
        
        // Confirm button
        Button(action: {
            hasAttempted = true
            errorMessage = nil
            if isFormValid {
                initiatePayment()
            }
        }) {
            HStack(spacing: 10) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                    Text("Traitement en cours…")
                        .font(.subheadline)
                        .fontWeight(.bold)
                } else if isWaitingForPayment {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    Text("Vérifier le paiement")
                        .font(.subheadline)
                        .fontWeight(.bold)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Confirmer le paiement")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isFormValid || !hasAttempted
                ? Color.qOrange
                : Color.qOrange.opacity(0.4)
            )
            .cornerRadius(14)
        }
        .disabled(isProcessing)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .sheet(isPresented: $showSafari, onDismiss: {
            // When user closes the in-app browser, check payment status
            if isWaitingForPayment, let txnId = transactionId {
                checkPaymentStatus(transactionId: txnId)
            }
        }) {
            if let url = checkoutURL {
                PaymentWebView(
                    url: url,
                    callbackURL: "qualiwo-api-fastapi.vercel.app/payments/callback"
                )
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Initiate FedaPay Payment
    private func initiatePayment() {
        // If already waiting, just check status
        if isWaitingForPayment, let txnId = transactionId {
            checkPaymentStatus(transactionId: txnId)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let names = nameParts
        let requestBody: [String: Any] = [
            "order_id": orderId,
            "phone_number": formattedPhone,
            "firstname": names.firstname,
            "lastname": names.lastname,
            "callback_url": "https://qualiwo-api-fastapi.vercel.app/payments/callback",
            "amount": totalAmount
        ]
        
        Task {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
                
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/payments/create")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    let paymentResponse = try JSONDecoder().decode(PaymentCreateResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        transactionId = paymentResponse.transaction_id
                        isProcessing = false
                        isWaitingForPayment = true
                        
                        // Open FedaPay checkout in-app browser
                        if let url = URL(string: paymentResponse.checkout_url) {
                            checkoutURL = url
                            showSafari = true
                        }
                    }
                } else {
                    // Parse error from server
                    let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let message = errorResponse?["detail"] as? String
                        ?? errorResponse?["message"] as? String
                        ?? "Erreur lors de l'initialisation du paiement"
                    
                    DispatchQueue.main.async {
                        errorMessage = message
                        isProcessing = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur réseau: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Check Payment Status
    private func checkPaymentStatus(transactionId: Int) {
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                let url = URL(string: "https://qualiwo-api-fastapi.vercel.app/payments/status/\(transactionId)")!
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                let statusResponse = try JSONDecoder().decode(PaymentStatusResponse.self, from: data)
                
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    switch statusResponse.status {
                    case "approved":
                        isWaitingForPayment = false
                        onSuccess()
                        
                    case "pending":
                        errorMessage = "Le paiement est en attente de confirmation. Veuillez patienter ou réessayer."
                        
                    case "canceled", "cancelled":
                        isWaitingForPayment = false
                        errorMessage = "Le paiement a été annulé."
                        self.transactionId = nil
                        
                    case "declined":
                        isWaitingForPayment = false
                        errorMessage = "Le paiement a été refusé. Veuillez réessayer."
                        self.transactionId = nil
                        
                    default:
                        errorMessage = "Statut du paiement: \(statusResponse.status)"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isProcessing = false
                    errorMessage = "Impossible de vérifier le paiement. Réessayez."
                }
            }
        }
    }
}

// MARK: - Payment WebView (auto-closes on callback redirect)
struct PaymentWebView: UIViewRepresentable {
    let url: URL
    let callbackURL: String
    @Environment(\.dismiss) var dismiss
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: PaymentWebView
        
        init(_ parent: PaymentWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString,
               url.contains(parent.callbackURL) {
                // FedaPay redirected to callback → payment done, close webview
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
                return
            }
            decisionHandler(.allow)
        }
    }
}
