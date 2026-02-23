//
//  WelcomeCategoryRow.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 17/02/2026.
//

import SwiftUI

// MARK: - Welcome Category Row (Android Style)
struct WelcomeCategoryRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isAssetIcon: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            if isAssetIcon {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
                    .frame(width: 28)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 28)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
