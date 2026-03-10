//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  Home.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// New combined authentication view model
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    
    func signUp(onSuccess: @escaping () -> Void) {
        if let emailError = InputValidator.validateEmail(email) {
            errorMessage = emailError; return
        }
        if let passwordError = InputValidator.validatePassword(password) {
            errorMessage = passwordError; return
        }

        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email.trimmingCharacters(in: .whitespaces), password: password)
                let user = DBUser(auth: returnedUserData)
                try await UserManager.shared.createNewUser(user: user)
                print("Sign up successful!")
                onSuccess()
            } catch {
                let nsError = error as NSError
                if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    DispatchQueue.main.async {
                        withAnimation { self.errorMessage = "Email already in use." }
                    }
                } else {
                    DispatchQueue.main.async {
                        withAnimation { self.errorMessage = error.localizedDescription }
                    }
                }
            }
        }
    }

    func signIn(onSuccess: @escaping () -> Void) {
        if let emailError = InputValidator.validateEmail(email) {
            errorMessage = emailError; return
        }
        if password.isEmpty {
            errorMessage = "Please enter your password."
            return
        }

        Task {
            do {
                let userData = try await AuthenticationManager.shared.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
                print("Sign in successful!")
                print(userData)
                onSuccess()
            } catch {
                DispatchQueue.main.async {
                    withAnimation { self.errorMessage = error.localizedDescription }
                }
            }
        }
    }
}

struct AuthView: View {
    var onLoginSuccess: () -> Void
    @StateObject private var viewModel = AuthViewModel()

    @State private var activeIntro: PageIntro = pageIntros[0]
    @State private var isSignUp = true  // true = Sign Up mode; false = Sign In mode

    // Profile setup management
    @State private var showProfileSetup: Bool = false
    @State private var authenticatedUserID: String? = nil
    @State private var isCheckingProfile: Bool = false
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            // Main auth flow
            GeometryReader { geo in
                let size = geo.size

                IntroView(intro: $activeIntro, size: size) {
                // Combined Authentication View
                VStack(spacing: 10) {
                    // Email field
                    CustomTextField(
                        text: $viewModel.email,
                        hint: "Email Address",
                        leadingIcon: Image(systemName: "envelope")
                    )
                    
                    // Password field
                    CustomTextField(
                        text: $viewModel.password,
                        hint: "Password",
                        leadingIcon: Image(systemName: "lock"),
                        isPassword: true
                    )
                    
                    Spacer(minLength: 10)
                    
                    // Primary action button (Sign Up / Sign In)
                    Button {
                        if isSignUp {
                            viewModel.signUp(onSuccess: handleAuthSuccess)
                        } else {
                            viewModel.signIn(onSuccess: handleAuthSuccess)
                        }
                    } label: {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background {
                                Capsule().fill(.black)
                            }
                    }
                    
                    // Toggle mode button
                    Button {
                        isSignUp.toggle()
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 25)
            }
            }
            .padding(15)
            .opacity(showProfileSetup ? 0 : 1)  // Hide when showing profile setup

            // Profile Setup Overlay
            if showProfileSetup, let userID = authenticatedUserID {
                ProfileSetupView(userID: userID) {
                    // On completion, navigate to main app
                    onLoginSuccess()
                }
                .environmentObject(profileViewModel)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            // Loading indicator during profile check
            if isCheckingProfile {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Setting up your account...")
                            .fontWeight(.medium)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                }
            }

            // Error banner
            if let error = viewModel.errorMessage {
                VStack {
                    ErrorBannerView(message: error)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation{
                                    viewModel.errorMessage = nil
                                }
                            }
                        }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func checkProfileCompleteness(userID: String) async {
        await MainActor.run {
            isCheckingProfile = true
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        do {
            let snapshot = try await userRef.getDocument()

            if let data = snapshot.data(),
               let username = data["username"] as? String,
               !username.isEmpty {
                // Profile complete → go to main app
                await MainActor.run {
                    isCheckingProfile = false
                    onLoginSuccess()
                }
            } else {
                // Profile incomplete → show ProfileSetupView
                await MainActor.run {
                    isCheckingProfile = false
                    showProfileSetup = true
                }
            }
        } catch {
            print("Profile check error: \(error)")
            // Default to showing profile setup on error (safe fallback)
            await MainActor.run {
                isCheckingProfile = false
                showProfileSetup = true
            }
        }
    }

    private func handleAuthSuccess() {
        guard let userID = Auth.auth().currentUser?.uid else {
            viewModel.errorMessage = "Authentication failed. Please try again."
            return
        }

        authenticatedUserID = userID

        Task {
            await checkProfileCompleteness(userID: userID)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Intro view remains unchanged
struct IntroView<ActionView: View>: View {
    @Binding var intro: PageIntro
    var size: CGSize
    var actionView: ActionView
    
    init(intro: Binding<PageIntro>, size: CGSize, @ViewBuilder actionView: @escaping () -> ActionView) {
        self._intro = intro
        self.size = size
        self.actionView = actionView()
    }
    
    // Animation properties
    @State private var showView: Bool = false
    @State private var hideWholeView: Bool = false
    
    var body: some View {
        VStack {
            // Back button and Skip button
            HStack {
                // Back button (if not on first intro)
                if intro != pageIntros.first {
                    Button {
                        changeIntro(true)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .contentShape(Rectangle())
                    }
                    .padding(10)
                    .offset(y: showView ? 0 : -200)
                    .offset(y: hideWholeView ? -200 : 0)
                }

                Spacer()

                // Skip button (show on pages before auth)
                if !intro.displayAction {
                    Button {
                        skipToAuth()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .offset(y: showView ? 0 : -200)
                    .offset(y: hideWholeView ? -200 : 0)
                }
            }
            
            // Title
            HStack {
                Text(intro.title)
                    .font(.title)
                    .fontWidth(.expanded)
                    .fontWeight(.heavy)
                Spacer()
            }
            .padding()
            
            GeometryReader { proxy in
                let size = proxy.size

                // Use SF Symbols for the onboarding icons
                Image(systemName: intro.introAssetImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.primary)
                    .font(.system(size: 100, weight: .light))
                    .padding(40)
                    .frame(width: size.width, height: size.height)
            }
            .offset(y: showView ? 0 : -size.height / 2)
            .opacity(showView ? 1 : 0)
            
            Text(intro.subTitile)
                .fontWidth(.expanded)
                .fontWeight(.heavy)
            
            if !intro.displayAction {
                Group {
                    Spacer(minLength: 25)
                    
                    CustomIndicatorView(
                        totalPages: filteredPages.count,
                        currentPage: filteredPages.firstIndex(of: intro) ?? 0,
                        activeTint: .gray
                    )
                    
                    Spacer(minLength: 10)
                    
                    Button {
                        changeIntro()
                    } label: {
                        Text("Next")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: size.width * 0.4)
                            .padding(.vertical, 15)
                            .background {
                                Capsule().fill(.black)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Action view: here our combined Auth view is injected
                actionView
                    .offset(y: showView ? 0 : size.height / 2)
                    .opacity(showView ? 1 : 0)
            }
        } // end of VStack
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(y: showView ? 0 : size.height / 2)
        .opacity(showView ? 1 : 0)
        .offset(y: hideWholeView ? size.height / 2 : 0)
        .opacity(hideWholeView ? 0 : 1)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                showView = true
            }
        }
    }
    
    func changeIntro(_ isPrevious: Bool = false) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            hideWholeView = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = pageIntros.firstIndex(of: intro),
               (isPrevious ? index != 0 : index != pageIntros.count - 1) {
                intro = isPrevious ? pageIntros[index - 1] : pageIntros[index + 1]
            } else {
                intro = isPrevious ? pageIntros[0] : pageIntros[pageIntros.count - 1]
            }

            hideWholeView = false
            showView = false

            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showView = true
            }
        }
    }

    func skipToAuth() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            hideWholeView = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Jump to last page (auth page)
            intro = pageIntros.last!

            hideWholeView = false
            showView = false

            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showView = true
            }
        }
    }

    var filteredPages: [PageIntro] {
        return pageIntros.filter { !$0.displayAction }
    }
}

struct ErrorBannerView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.callout)
            .padding()
            //.frame(maxWidth: .infinity)
            //.background(Color.red.opacity(0.9))
            .foregroundColor(.white)
            .padding(.horizontal)
            .background {
                Capsule().fill(.red)
            }
    }
}
