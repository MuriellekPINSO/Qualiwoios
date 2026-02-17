//
//  ContentView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO  on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            MainChatView(isLoggedIn: $isLoggedIn)
        } else {
            AuthView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}
