//Zayn

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

// MARK: - LOGIN PAGE
struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var errorMessage: String?
    @State private var showVerifyMessage = false
    @StateObject private var friendStore = FriendStore()
    @EnvironmentObject private var healthkitEngine: HealthkitEngine
    
    let signUpScreen = SignUpView()
    
    var body: some View {
        if userIsLoggedIn {
            MainTabView(userIsLoggedIn:$userIsLoggedIn) // Navigate to the next screen
                .environmentObject(friendStore).environmentObject(healthkitEngine)
            
//        if userIsLoggedIn {
            Xp_System()  // Trigger XP processing
        } else {
            content
        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                Image("fitpalz_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 330)
                    .padding(.top, 55)
                
                Text("Welcome")
                    .foregroundColor(.white)
                    .offset(y: -55)
                    .font(.system(size: 31, weight: .bold))
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .strokeBorder(Color(hex: "7b6af4"), lineWidth: 2)
                    )
                    .padding(.bottom, 15)
                    .offset(y: -30)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .strokeBorder(Color(hex: "7b6af4"), lineWidth: 2)
                    )
                    .padding(.bottom, 15)
                    .offset(y: -30)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                        .offset(y: -25)
                }
                
                
                Button("Sign In") {
                    login()
                }
                .font(.system(size: 24))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "7b6af4"))
                .foregroundColor(.white)
                .cornerRadius(40)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                

                
                Button(action: {
                    googleSignIn()
                }) {
                    Text("Sign in with Google")
                        .font(.system(size: 17, weight: .bold))
            
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)

                
                
                NavigationLink("Don't have an account? Sign Up!") {
                    signUpScreen
                }
                .padding()
                .font(.system(size: 17, weight: .bold))
                .underline(true, color: .blue)
                .frame(maxWidth: .infinity)
                .underline(true, color: .blue)
                .foregroundColor(.blue)
                .cornerRadius(10)
                
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(width: 350)

                
                
                // (Email Verification Button)
                if showVerifyMessage {
                    Button("Resend Verification Email") {
                        resendVerificationEmail()
                    }
                    .font(.system(size: 20))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(y: -30)
                }
            }
            .background(Color(hex: "191919").ignoresSafeArea()) 
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        user.reload { _ in
                            self.userIsLoggedIn = user.isEmailVerified
                            if !user.isEmailVerified {
                                showVerifyMessage = true // Show resend button if not verified
                            } else {
                                showVerifyMessage = false // Hide if verified
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - LOGIN/EMAIL VERIFICATION
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else { return }
            user.reload { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if user.isEmailVerified {
                    let db = Firestore.firestore()
                        if let uid = user.uid as String? {
                            db.collection("users").document(uid).updateData([
                                "accountStatus": "verified"
                            ]) { error in
                                if let error = error {
                                    print("Failed to update accountStatus: \(error.localizedDescription)")
                                } else {
                                    print("accountStatus updated to verified.")
                                }
                            }
                        }

                        userIsLoggedIn = true
                        showVerifyMessage = false
                } else {
                    errorMessage = "Please verify your email before continuing."
                    showVerifyMessage = true
                    try? Auth.auth().signOut()
                }
            }
        }
    }
    
    func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if let error = error {
                errorMessage = "Failed to resend email: \(error.localizedDescription)"
            } else {
                errorMessage = "Verification email sent!"
            }
        }
    }
    // MARK: - GOOGLE SIGN IN
    func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            print("No root view controller found.")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            guard error == nil else {
                print("Google Sign-In error: \(error!.localizedDescription)")
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase Sign-In error: \(error.localizedDescription)")
                    return
                }
                guard let firebaseUser = result?.user else { return }
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(firebaseUser.uid)
                docRef.getDocument { document, error in
                    if let document = document, document.exists {
                        print("User already exists in Firestore.")
                    } else {
                        let firstName = firebaseUser.displayName ?? "New User"
                        let email = firebaseUser.email ?? ""
                        let userData: [String: Any] = [
                            "firstName": firstName,
                            "email": email,
                            "uid": firebaseUser.uid,
                            "signUpDate": FieldValue.serverTimestamp(),
                            "provider": "google"
                        ]
                        db.collection("users").document(firebaseUser.uid).setData(userData) { error in
                            if let error = error {
                                print("Firestore save error: \(error.localizedDescription)")
                            } else {
                                print("User saved to Firestore via Google Sign-In.")
                            }
                        }
                    }
                    userIsLoggedIn = true
                }
            }
        }
    }
}

// MARK: - SIGN UP PAGE
// SIGNUP PAGE WITH EMAIL VERIFICATION
struct SignUpView: View {
    @State private var firstName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phoneNumber = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex: "7b6af4"), lineWidth: 1)
                    )

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex: "7b6af4"), lineWidth: 1)
                    )
                    .padding(.bottom, 8)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex: "7b6af4"), lineWidth: 1)
                    )
                    .padding(.bottom, 8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex: "7b6af4"), lineWidth: 1)
                    )
                    .padding(.bottom, 8)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex: "7b6af4"), lineWidth: 1)
                    )
                    .padding(.bottom, 8)

                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Sign Up") {
                    signUp()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "7b6af4"))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    // MARK: - SIGN UP
    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        if let validationError = isValidPassword(password) {
            errorMessage = validationError
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            result?.user.sendEmailVerification { error in
                if let error = error {
                    print("Failed to send email verification: \(error.localizedDescription)")
                } else {
                    print("Verification email sent!")
                }
            }
           // saveUserToFirestore()
        }
    }
    
       // MARK: - STORING TO FIREBASE
    func saveUserToFirestore(user: User) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "firstName": firstName,
            "phoneNumber": normalizePhoneNumber(phoneNumber),
            "email": user.email ?? "",
            "uid": user.uid,
            "signUpDate": FieldValue.serverTimestamp(),
            "accountStatus": user.isEmailVerified ? "verified" : "pending_verification",
            "totalXP": 0,  // Initial XP value for the user
            "weeklyXP": 0  // Initial weekly XP value
        ]
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
            } else {
                print("User data saved to Firestore.")
            }
        }
    }

    func normalizePhoneNumber(_ raw: String) -> String {
        let digits = raw.filter { "0123456789".contains($0) }
        if raw.trimmingCharacters(in: .whitespaces).first == "+" {
            return "+" + digits
        } else if digits.count == 10 {
            return "+1" + digits
        } else if digits.count == 11 && digits.first == "1" {
            return "+" + digits
        } else {
            return "+" + digits
        }
    }
    
    // MARK: - PASSWORD CHECKS
    func isValidPassword(_ password: String) -> String? {
        if password.count < 8 {
            return "Password must be at least 8 characters."
        }
        if password.count > 24 {
            return "Password must be no more than 24 characters."
        }
        let upper = ".*[A-Z]+.*"
        let lower = ".*[a-z]+.*"
        let special = ".*[^A-Za-z0-9]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", upper).evaluate(with: password) {
            return "Password must include at least one uppercase letter."
        }
        if !NSPredicate(format: "SELF MATCHES %@", lower).evaluate(with: password) {
            return "Password must include at least one lowercase letter."
        }
        if !NSPredicate(format: "SELF MATCHES %@", special).evaluate(with: password) {
            return "Password must include at least one special character."
        }
        return nil
    }
}
// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            SignUpView()
        }
    }
}
