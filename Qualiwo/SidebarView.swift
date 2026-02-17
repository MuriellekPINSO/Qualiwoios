//
//  SidebarView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 05/02/2026.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showSidebar: Bool
    var onSelectConversation: (ChatConversation) -> Void
    var onNewChat: () -> Void
    
    // Sample conversations (empty for now like Android)
    let conversations: [ChatConversation] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header: "Qualiwo" + X close
            HStack {
                Text("Qualiwo")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.qOrange)
                
                Spacer()
                
                Button(action: { withAnimation { showSidebar = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // MARK: - "+ Nouveau chat" button (orange, full width)
            Button(action: onNewChat) {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Nouveau chat")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.qOrange)
                .cornerRadius(10)
                .padding(.horizontal, 16)
            }
            
            // MARK: - Divider
            Divider()
                .background(Color.gray.opacity(0.2))
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            
            // MARK: - "Historique" Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Historique")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
                if conversations.isEmpty {
                    Text("Aucune conversation")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                } else {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(conversations) { conv in
                                Button(action: { onSelectConversation(conv) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(conv.title)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(conv.lastMessage)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(conv.time)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.qSurface)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // MARK: - User info bottom
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    // User avatar (orange circle like Android)
                    Circle()
                        .fill(Color.qOrange)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text("U")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Utilisateur")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Gratuit")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Three dots menu (Android style)
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                    }
                }
                .padding(.horizontal, 16)
                
                // MARK: - Logout button
                Button(action: { isLoggedIn = false }) {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))
                            .foregroundColor(.qOrange)
                        
                        Text("Déconnexion")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.qOrange)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.qSurface)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.qDarkBg.ignoresSafeArea())
    }
}

#Preview {
    SidebarView(
        isLoggedIn: .constant(true),
        showSidebar: .constant(true),
        onSelectConversation: { _ in },
        onNewChat: {}
    )
}
