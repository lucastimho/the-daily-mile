import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isShowingUserHint = false
    @State private var isLoggingIn = false
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and title
                VStack(spacing: 15) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 80))
                        .foregroundColor(ColorTheme.primary)
                    
                    Text("The Daily Mile")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Login form
                VStack(spacing: 25) {
                    VStack(spacing: 20) {
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textPrimary)
                            
                            TextField("Enter username", text: $username)
                                .padding()
                                .background(ColorTheme.cardBackground)
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textPrimary)
                            
                            SecureField("Enter password", text: $password)
                                .padding()
                                .background(ColorTheme.cardBackground)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    // Error message
                    if let error = appState.loginError {
                        Text(error)
                            .foregroundColor(ColorTheme.error)
                            .padding(.horizontal)
                    }
                    
                    // Login button
                    Button(action: {
                        isLoggingIn = true
                        
                        // Simulate a brief loading delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            appState.login(username: username, password: password)
                            isLoggingIn = false
                        }
                    }) {
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(ColorTheme.primary)
                                .cornerRadius(10)
                        } else {
                            Text("Log In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(ColorTheme.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 25)
                    .disabled(username.isEmpty || password.isEmpty || isLoggingIn)
                    .opacity((username.isEmpty || password.isEmpty) ? 0.6 : 1)
                    
                    // Demo users hint button
                    Button(action: {
                        isShowingUserHint.toggle()
                    }) {
                        Text("Show Demo Users")
                            .foregroundColor(ColorTheme.primary)
                    }
                    
                    if isShowingUserHint {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Demo Users:")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textPrimary)
                            
                            ForEach(User.demoUsers, id: \.id) { user in
                                HStack {
                                    Text("Username: \(user.username)")
                                    Spacer()
                                    Text("Password: \(user.password)")
                                }
                                .font(.caption)
                                .foregroundColor(ColorTheme.textSecondary)
                            }
                        }
                        .padding()
                        .background(ColorTheme.cardBackground)
                        .cornerRadius(8)
                        .padding(.horizontal, 25)
                    }
                }
                
                Spacer()
                
                // App version
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState(demoMode: true))
} 