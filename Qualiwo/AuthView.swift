//
//  AuthView.swift
//  Qualiwo
//
//  Created by Murielle KPINSO on 05/02/2026.
//

import SwiftUI

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            Color.qDarkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with floating icons
                ZStack {
                    // buy icon - top left
                    VStack {
                        HStack {
                            Image("buy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .opacity(0.9)
                                .padding(.leading, 30)
                                .padding(.top, 40)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // bag icon - top right
                    VStack {
                        HStack {
                            Spacer()
                            Image("sh")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .opacity(0.9)
                                .padding(.trailing, 40)
                                .padding(.top, 30)
                        }
                        Spacer()
                    }
                    
                    // car (cart) icon - middle left
                    VStack {
                        HStack {
                            Image("card")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .opacity(0.7)
                                .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(.top, 140)
                        Spacer()
                    }
                    
                    // shop icon - middle right
                    VStack {
                        HStack {
                            Spacer()
                            Image("shop")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55, height: 55)
                                .opacity(0.4)
                                .padding(.trailing, 50)
                        }
                        .padding(.top, 150)
                        Spacer()
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.42)
                
                Spacer(minLength: 0)
                
                // Bottom card
                if showRegister {
                    RegisterCard(isLoggedIn: $isLoggedIn, showRegister: $showRegister)
                        .transition(.move(edge: .trailing))
                } else {
                    LoginCard(isLoggedIn: $isLoggedIn, showRegister: $showRegister)
                        .transition(.move(edge: .leading))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showRegister)
    }
}

// MARK: - Login Card
struct LoginCard: View {
    @Binding var isLoggedIn: Bool
    @Binding var showRegister: Bool
    @State private var phone = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 18) {
            Text("Se connecter")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.bottom, 6)
            
            // Phone field
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.qOrange)
                
                TextField("", text: $phone)
                    .foregroundColor(.black)
                    .placeholder(when: phone.isEmpty) {
                        Text("Ex: +229 97123456")
                            .foregroundColor(.gray.opacity(0.6))
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            // Password field
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.qOrange)
                
                if showPassword {
                    TextField("", text: $password)
                        .foregroundColor(.black)
                        .placeholder(when: password.isEmpty) {
                            Text("Ex: SecurePass123!")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                } else {
                    SecureField("", text: $password)
                        .foregroundColor(.black)
                        .placeholder(when: password.isEmpty) {
                            Text("Ex: SecurePass123!")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            // Se connecter button
            Button(action: { isLoggedIn = true }) {
                Text("Se connecter")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.qOrange)
                    .cornerRadius(12)
            }
            .padding(.top, 4)
            
            // S'inscrire button
            Button(action: { showRegister = true }) {
                Text("S'inscrire")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.qOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.qOrange, lineWidth: 1.5)
                    )
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

// MARK: - Register Card
struct RegisterCard: View {
    @Binding var isLoggedIn: Bool
    @Binding var showRegister: Bool
    @State private var name = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 18) {
            Text("Créer un compte")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.bottom, 6)
            
            // Name field
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.qOrange)
                
                TextField("", text: $name)
                    .foregroundColor(.black)
                    .placeholder(when: name.isEmpty) {
                        Text("Ex: Jean Dupont")
                            .foregroundColor(.gray.opacity(0.6))
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            // Phone field
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.qOrange)
                
                TextField("", text: $phone)
                    .foregroundColor(.black)
                    .placeholder(when: phone.isEmpty) {
                        Text("Ex: +229 97123456")
                            .foregroundColor(.gray.opacity(0.6))
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            // Password field
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.qOrange)
                
                if showPassword {
                    TextField("", text: $password)
                        .foregroundColor(.black)
                        .placeholder(when: password.isEmpty) {
                            Text("Ex: SecurePass123!")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                } else {
                    SecureField("", text: $password)
                        .foregroundColor(.black)
                        .placeholder(when: password.isEmpty) {
                            Text("Ex: SecurePass123!")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            // S'inscrire button
            Button(action: { isLoggedIn = true }) {
                Text("S'inscrire")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.qOrange)
                    .cornerRadius(12)
            }
            .padding(.top, 4)
            
            // Se connecter button
            Button(action: { showRegister = false }) {
                Text("Se connecter")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.qOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.qOrange, lineWidth: 1.5)
                    )
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}



#Preview {
    AuthView(isLoggedIn: .constant(false))
}
