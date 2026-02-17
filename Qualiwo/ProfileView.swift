//
//  ProfileView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 05/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Back")
                            .font(.body)
                            .foregroundColor(.qOrange)
                    }
                    
                    Spacer()
                    
                    Text("Profile")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Edit")
                            .font(.body)
                            .foregroundColor(.qOrange)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile image
                        VStack(spacing: 14) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .stroke(Color.qOrange, lineWidth: 3)
                                    .frame(width: 130, height: 130)
                                    .overlay(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.5)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 122, height: 122)
                                            .overlay(
                                                Text("U")
                                                    .font(.system(size: 52, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    )
                                
                                // Camera button
                                Button(action: {}) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.qOrange)
                                            .frame(width: 34, height: 34)
                                        
                                        Image("camera")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.white)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                                .offset(x: -5, y: -5)
                            }
                            
                            Text("Utilisateur")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("+33 6 12 34 56 78")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)
                        
                        // ACCOUNT section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ACCOUNT")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 20)
                            
                            ProfileRow(imageName: "car", title: "Account Settings")
                            ProfileRow(imageName: "privacy", title: "Notification Preferences")
                        }
                        
                        // COMMERCE section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COMMERCE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 20)
                            
                            ProfileRow(imageName: "payment", title: "Payment Methods")
                            ProfileRow(imageName: "pending", title: "Order History")
                        }
                        
                        // SUPPORT section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUPPORT")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 20)
                            
                            ProfileRow(imageName: "help", title: "Help Center")
                            ProfileRow(imageName: "privacy", title: "Privacy Policy")
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ProfileRow: View {
    let imageName: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.qCardBg)
                        .frame(width: 40, height: 40)
                    
                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.qOrange)
                        .frame(width: 18, height: 18)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ProfileView()
}
