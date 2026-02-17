//
//  Theme.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 05/02/2026.
//

import SwiftUI

// MARK: - App Colors
extension Color {
    static let qDarkBg = Color(red: 0.07, green: 0.06, blue: 0.05)
    static let qCardBg = Color(red: 0.13, green: 0.12, blue: 0.11)
    static let qOrange = Color(red: 0.91, green: 0.55, blue: 0.38)
    static let qInputBg = Color(red: 0.18, green: 0.17, blue: 0.16)
    static let qWhiteCard = Color.white
    
    // New Premium Colors
    static let qSurface = Color(red: 0.16, green: 0.15, blue: 0.14)
    static let qSurfaceLight = Color(red: 0.22, green: 0.21, blue: 0.20)
    static let qTextPrimary = Color(white: 0.95)
    static let qTextSecondary = Color(white: 0.7)
    
    // Gradients
    static let qGradientPrimary = LinearGradient(
        colors: [Color(red: 0.91, green: 0.55, blue: 0.38), Color(red: 0.85, green: 0.45, blue: 0.30)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let qGradientDark = LinearGradient(
        colors: [Color.qCardBg, Color.qDarkBg],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Placeholder modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
