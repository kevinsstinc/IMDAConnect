//
//  SignInView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 1/6/25.
//

import SwiftUI
import Combine
import FirebaseAnalytics

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @FocusState private var focus: FocusableField?
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func loginWithEmailPassword() {
        Task {
            isLoading = true
            if await viewModel.signInWithEmailPassword(email: email, password: password) == true {
                isUserLoggedIn = true
            } else {
                errorMessage = "Invalid credentials. Please try again."
            }
            isLoading = false
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0, blue: 0.3),
                    Color(red: 0.4, green: 0.1, blue: 0.5)
                ]),
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: isAnimating)
            .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 18) {
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        icon: "at",
                        placeholder: "Email",
                        text: $email,
                        isSecure: false,
                        focusField: .email,
                        focus: $focus
                    )
                    .onSubmit { focus = .password }
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true,
                        focusField: .password,
                        focus: $focus
                    )
                    .onSubmit { loginWithEmailPassword() }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: loginWithEmailPassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(isValid ? Color.white.opacity(0.15) : Color.gray.opacity(0.3))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .contentShape(Rectangle())
                    }
                    .disabled(!isValid)
                    
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: 6)
                .padding()
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
        .onAppear { isAnimating = true }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationViewModel())
}

