//
//  PaymentView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 19/02/2026.
//

import SwiftUI

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
            
            // Bottom: Total + Article count
            HStack {
                Text("Total: \(formatPrice(totalAmount)) CFA")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("1 ART.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.qOrange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
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
        }
        .padding(.horizontal, 20)
        
        Spacer().frame(height: 20)
        
        // Confirm button
        Button(action: {
            hasAttempted = true
            if isFormValid {
                processPayment()
            }
        }) {
            HStack(spacing: 10) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
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
    }
    
    private func processPayment() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            onSuccess()
        }
    }
}
