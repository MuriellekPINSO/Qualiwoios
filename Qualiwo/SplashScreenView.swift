//
//  SplashScreenView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 19/02/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoRotation: Double = -30
    @State private var bgGlow: Double = 0.0
    @State private var isFinished = false
    
    let onFinished: () -> Void
    
    var body: some View {
        ZStack {
            // Light background matching the Android splash
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            // Subtle radial glow behind logo
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.qOrange.opacity(bgGlow * 0.15),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo in white rounded container
                ZStack {
                    // White card shadow
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .rotationEffect(.degrees(logoRotation))
                
                Spacer()
            }
        }
        .onAppear {
            // Phase 1: Logo appears with spring bounce
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
                logoRotation = 0
            }
            
            // Phase 2: Glow pulse
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                bgGlow = 1.0
            }
            
            // Phase 3: Logo pulse then fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    logoScale = 1.1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    logoScale = 0.8
                    logoOpacity = 0.0
                    bgGlow = 0.0
                }
            }
            
            // Phase 4: Transition to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                onFinished()
            }
        }
    }
}
