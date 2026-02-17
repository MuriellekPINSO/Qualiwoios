//
//  LoadingIndicatorView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 17/02/2026.
//

import SwiftUI
import Combine

// MARK: - Loading Indicator (Android Style)
struct LoadingIndicatorView: View {
    @State private var currentStep = 0
    @State private var dotCount = 0
    
    let steps = [
        "Analyse de votre demande",
        "Recherche des produits correspondants",
        "Vérification de disponibilités"
    ]
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let stepTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    var dots: String {
        String(repeating: ".", count: (dotCount % 3) + 1)
    }
    
    @State private var isRotating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo Qualiwo with white circle background + rotation
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isRotating)
            }
            .onAppear { isRotating = true }
            
            Text(steps[currentStep] + dots)
                .font(.subheadline)
                .foregroundColor(.gray)
                .animation(.none, value: dotCount)
        }
        .padding(.vertical, 8)
        .padding(.leading, 4)
        .onReceive(timer) { _ in
            dotCount += 1
        }
        .onReceive(stepTimer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = (currentStep + 1) % steps.count
            }
        }
    }
}
