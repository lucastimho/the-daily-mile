import SwiftUI

struct SignupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var experience: UserProfile.RunnerExperience = .beginner
    @State private var weeklyGoal: String = "10" // Default goal
    
    @State private var isSigningUp = false
    @State private var currentPage = 0 // For multi-page form
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: {
                        if currentPage > 0 {
                            currentPage -= 1
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(ColorTheme.primary)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.clear)
                        .padding(.trailing)
                }
                .padding(.top, 16)
                
                // Form Pages
                TabView(selection: $currentPage) {
                    // Page 1: Account details
                    accountDetailsView
                        .tag(0)
                    
                    // Page 2: Personal details
                    personalDetailsView
                        .tag(1)
                    
                    // Page 3: Running preferences
                    runningPreferencesView
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Error message
                if let error = appState.signupError {
                    Text(error)
                        .foregroundColor(ColorTheme.error)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
                
                // Pagination indicator
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(index == currentPage ? ColorTheme.primary : Color.gray.opacity(0.3))
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var accountDetailsView: some View {
        VStack(spacing: 24) {
            Text("Create Your Account")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.top)
            
            VStack(spacing: 16) {
                FormField(title: "Username", text: $username, placeholder: "Choose a username", keyboardType: .default)
                
                FormField(title: "Password", text: $password, placeholder: "Enter password", isSecure: true)
                
                FormField(title: "Confirm Password", text: $confirmPassword, placeholder: "Confirm password", isSecure: true)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                currentPage = 1
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAccountFormValid ? ColorTheme.primary : Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
            }
            .disabled(!isAccountFormValid)
            .padding(.bottom, 24)
        }
    }
    
    private var personalDetailsView: some View {
        VStack(spacing: 24) {
            Text("Personal Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.top)
            
            VStack(spacing: 16) {
                FormField(title: "Name", text: $name, placeholder: "Your name", keyboardType: .default)
                
                FormField(title: "Age", text: $age, placeholder: "Age in years", keyboardType: .numberPad)
                
                FormField(title: "Weight (kg)", text: $weight, placeholder: "Weight in kg", keyboardType: .decimalPad)
                
                FormField(title: "Height (cm)", text: $height, placeholder: "Height in cm", keyboardType: .decimalPad)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                currentPage = 2
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPersonalFormValid ? ColorTheme.primary : Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
            }
            .disabled(!isPersonalFormValid)
            .padding(.bottom, 24)
        }
    }
    
    private var runningPreferencesView: some View {
        VStack(spacing: 24) {
            Text("Running Experience")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Experience Level")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Picker("Experience Level", selection: $experience) {
                    ForEach(UserProfile.RunnerExperience.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Weekly Goal (Miles)")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                    .padding(.top, 8)
                
                TextField("Weekly Goal", text: $weeklyGoal)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                signUp()
            }) {
                if isSigningUp {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.primary)
                        .cornerRadius(10)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunningFormValid ? ColorTheme.primary : Color.gray)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 24)
            .disabled(!isRunningFormValid || isSigningUp)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Helper Methods
    
    private var isAccountFormValid: Bool {
        !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    private var isPersonalFormValid: Bool {
        !name.isEmpty && 
        !age.isEmpty && Int(age) != nil && Int(age)! > 0 &&
        !weight.isEmpty && Double(weight) != nil && Double(weight)! > 0 &&
        !height.isEmpty && Double(height) != nil && Double(height)! > 0
    }
    
    private var isRunningFormValid: Bool {
        !weeklyGoal.isEmpty && Int(weeklyGoal) != nil && Int(weeklyGoal)! > 0
    }
    
    private func signUp() {
        isSigningUp = true
        
        // Create user profile
        let profile = UserProfile(
            name: name,
            age: Int(age) ?? 0,
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            experience: experience,
            weeklyGoal: Int(weeklyGoal) ?? 10
        )
        
        // Simulate a brief delay for sign-up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let success = appState.signup(
                username: username, 
                password: password, 
                confirmPassword: confirmPassword,
                profile: profile
            )
            
            isSigningUp = false
            
            // If successful, login will have been performed already
            if !success {
                // Error will be shown from appState.signupError
            }
        }
    }
}

// MARK: - Form Components

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(10)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(10)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress)
            }
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AppState(demoMode: true))
} 