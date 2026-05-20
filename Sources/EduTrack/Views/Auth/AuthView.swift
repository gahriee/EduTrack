import SwiftUI
import UIKit

struct AuthView: View {
    @EnvironmentObject var dataStore: DataStore
    
    @State private var isLogin = true
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    Text("EduTrack")
                        .font(.largeTitle.weight(.bold))
                    Text("Student Attendance Manager")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)
                
                // Card
                VStack(spacing: 24) {
                    Picker("Mode", selection: $isLogin) {
                        Text("Log In").tag(true)
                        Text("Register").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(spacing: 16) {
                        if !isLogin {
                            AuthTextField(title: "Name", text: $name)
                        }
                        
                        AuthTextField(title: "Email", text: $email)
                            .keyboardType(.emailAddress)
                        
                        AuthTextField(title: "Password", text: $password, isSecure: true)
                        
                        if !isLogin {
                            AuthTextField(title: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await handleSubmit()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isLogin ? "Log In" : "Create Account")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                }
                .padding(24)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .animation(.easeInOut, value: isLogin)
        }
    }
    
    private func handleSubmit() async {
        errorMessage = ""
        
        // Basic validation
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        if !isLogin {
            if name.isEmpty {
                errorMessage = "Please enter your name."
                return
            }
            if password != confirmPassword {
                errorMessage = "Passwords do not match."
                return
            }
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters."
                return
            }
        }
        
        isLoading = true
        do {
            if isLogin {
                try await dataStore.login(email: email, password: password)
            } else {
                try await dataStore.register(name: name, email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
