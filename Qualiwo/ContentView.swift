//
//  ContentView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO  on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                Group {
                    if isLoggedIn {
                        MainChatView(isLoggedIn: $isLoggedIn)
                    } else {
                        AuthView(isLoggedIn: $isLoggedIn)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
    }
}

#Preview {
    ContentView()
}
