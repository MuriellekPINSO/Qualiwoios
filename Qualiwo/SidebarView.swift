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
    
    @State private var searchText = ""
    @State private var chatsExpanded = true
    
    // Sample conversations
    let conversations: [ChatConversation] = [
        ChatConversation(
            title: "T-shirts disponibles en ligne",
            lastMessage: "Oui, nous avons plusieurs T-shirts en stock...",
            time: "09:02",
            messages: [
                ChatMessage(content: "je cherche des t-shirts", isFromUser: true, timestamp: Date()),
                ChatMessage(content: "Oui, nous avons plusieurs T-shirts en stock...", isFromUser: false, timestamp: Date())
            ]
        ),
        ChatConversation(
            title: "Correction quotidienne",
            lastMessage: "Voici le résumé des corrections...",
            time: "10:02",
            messages: [
                ChatMessage(content: "Voici le résumé des corrections...", isFromUser: false, timestamp: Date())
            ]
        ),
        ChatConversation(
            title: "Animation Hero Section",
            lastMessage: "La section hero est maintenant animée...",
            time: "10:02",
            messages: [
                ChatMessage(content: "La section hero est maintenant animée...", isFromUser: false, timestamp: Date())
            ]
        ),
        ChatConversation(
            title: "Plateforme Aura.build",
            lastMessage: "Design de la plateforme finalisé",
            time: "10:02",
            messages: [
                ChatMessage(content: "Design de la plateforme finalisé", isFromUser: false, timestamp: Date())
            ]
        ),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                }
                
                Circle()
                    .fill(Color.qOrange)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text("U")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // New chat button
            Button(action: onNewChat) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Nouveau chat")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                TextField("", text: $searchText)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Rechercher des chats")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.subheadline)
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.qInputBg)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Chats section
            VStack(alignment: .leading, spacing: 0) {
                Button(action: { withAnimation { chatsExpanded.toggle() } }) {
                    HStack {
                        Text("Vos chats")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                
                if chatsExpanded {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(conversations) { conv in
                                Button(action: { onSelectConversation(conv) }) {
                                    VStack(alignment: .leading, spacing: 4) {
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
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.qInputBg)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // User info bottom
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("U")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Utilisateur")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Gratuit")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                
                // Logout button
                Button(action: { isLoggedIn = false }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrowleft.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.qOrange)
                        
                        Text("Déconnexion")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.qOrange)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.qInputBg)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.qDarkBg)
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
