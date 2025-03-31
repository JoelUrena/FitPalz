
////LOGIN PAGE
//struct ContentView: View {
//    @State private var email = ""
//    @State private var password = ""
//    //    @State private var errorMessage: String?
//    @State private var userIsLoggedIn: Bool
//
//    // Custom initializer to inject userIsLoggedIn for the preview
//    init(userIsLoggedIn: Bool = false) {
//        _userIsLoggedIn = State(initialValue: userIsLoggedIn)
//    }
//
//    var body: some View {
//        NavigationStack {
//            if userIsLoggedIn {
//                ListView() // Show ListView when logged in
//            } else {
//                content // Show login UI when not logged in
//            }
//        }
//    }
//


//            // Sign Up Button
//            NavigationLink(destination: SignUpView()) { // NavigationLink now works because it's wrapped in NavigationStack
//                Text("Don't have an account? Sign Up!")
//                    .padding()
//                    .font(.system(size: 17, weight: .bold))
//                    .underline(true, color: .blue)
//                    .frame(maxWidth: .infinity)
//                    .foregroundColor(.blue)
//                    .cornerRadius(10)
//                    .offset(y: -200)
//            }
//
//            .padding(.horizontal, 20)
//            Spacer()
//                .frame(width: 350)
//            //                    .onAppear {
//            //                        Auth.auth().addStateDidChangeListener { auth, user in
//            //                            if user != nil {
//            //                                userIsLoggedIn.toggle()
//            //                            }
//            //                        }
//            //                    }
//
//        }
//        .background(Color.black)
//        .edgesIgnoringSafeArea(.all) // Make the background cover the entire screen
//    }
//
//    func login() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//        }
//    }
//}
//
//    //SIGNUP PAGE
//    struct SignUpView: View {
//        @State private var firstName = ""
//        @State private var lastName = ""
//        @State private var email = ""
//        @State private var password = ""
//        @State private var confirmPassword = ""
//        @State private var errorMessage: String?
//
//        var body: some View {
//            ZStack {
//                Color.black // background color to black
//
//                VStack {
//                    Image("logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 330, height: 330)
//                        .padding(.top, -255)
//
//                    Text("Sign Up")
//                        .foregroundColor(.white)
//                        .offset(y: -35)
//                        .font(.system(size: 31, weight: .bold))
//
//                    // Sign-up form UI elements
//                    //                TextField("First Name", text: $firstName)
//                    //                    .padding()
//                    //                    .background(Color.gray.opacity(0.2))
//                    //                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
//                    //                    .cornerRadius(2)
//                    //                    .padding(.bottom, 8)
//                    //
//                    //                TextField("Last Name", text: $lastName)
//                    //                    .padding()
//                    //                    .background(Color.gray.opacity(0.2))
//                    //                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
//                    //                    .cornerRadius(2)
//                    //                    .padding(.bottom, 8)
//
//                    TextField("New Email", text: $email)
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
//                        .cornerRadius(2)
//                        .padding(.bottom, 8)
//
//                    SecureField("New Password", text: $password)
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
//                        .cornerRadius(2)
//                        .padding(.bottom, 8)
//
//                    //                SecureField("Confirm Password", text: $confirmPassword)
//                    //                    .padding()
//                    //                    .background(Color.gray.opacity(0.2))
//                    //                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
//                    //                    .cornerRadius(2)
//                    //                    .padding(.bottom, 8)
//
//                    // Display error message if any
//                    if let errorMessage = errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding(.bottom, 15)
//                    }
//
//                    Button("Sign Up") {
//                        signUp()
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(red: 0.48, green: 0.41, blue: 0.95))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 115)
//                    .offset(y: 45)
//
//                    // Back Button
//                    NavigationLink(destination: SignUpView()) { // NavigationLink now works because it's wrapped in NavigationStack
//                        Text("Have an account? Sign In!")
//                            .padding()
//                            .font(.system(size: 17, weight: .bold))
//                            .underline(true, color: .blue)
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(.blue)
//                            .cornerRadius(10)
//                            .offset(y: 50)
//                    }
//                }
//                .padding()
//                .foregroundColor(.white)  // Set the text color to white for contrast
//            }
//            .edgesIgnoringSafeArea(.all)  // Ensures the background covers the entire screen
//            .navigationBarTitle("Sign Up", displayMode: .inline)
//        }
//
//        func signUp() {
//            guard password == confirmPassword else {
//                errorMessage = "Passwords do not match."
//                return
//            }
//
//            Auth.auth().createUser(withEmail: email, password: password) { result, error in
//                if let error = error {
//                    errorMessage = error.localizedDescription
//                    return
//                }
//
//                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.displayName = "\(firstName) \(lastName)"
//                changeRequest?.commitChanges { error in
//                    if let error = error {
//                        print("Error saving name: \(error.localizedDescription)")
//                    } else {
//                        print("Name saved successfully!")
//                    }
//                }
//
//                print("User signed up successfully.")
//            }
//        }
//
//
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                // Preview for ContentView (Login View)
//                ContentView(userIsLoggedIn: false)
//
//                // Preview for SignUpView (Sign Up View)
//                //SignUpView()
//            }
//        }
//    }
//}


import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// LOGIN PAGE
struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var errorMessage: String?
    
    let signUpScreen = SignUpView()
    
    var body: some View {
        if userIsLoggedIn {
            HomeView() // Navigate to the next screen
        } else {
            content
        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 330)
                    .padding(.top, 55)
                
                Text("Welcome")
                    .foregroundColor(.white)
                    .offset(y: -55)
                    .font(.system(size: 31, weight: .bold))
                
                // Email TextField
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(.plain)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .foregroundColor(.white)
                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
                    .cornerRadius(2)
                    .padding(.bottom, 8)
                    .offset(y: -35)
                
                // Password SecureField
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(PlainTextFieldStyle())
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .foregroundColor(.blue)
                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
                    .cornerRadius(2)
                    .padding(.bottom, 15)
                    .offset(y: -30)
                
                // Sign In Button
                Button("Sign In") {
                    login()
                }
                .font(.system(size: 24))
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                .cornerRadius(10)
                .offset(y: -30)
                
                // Google Sign-In Button
                Button("Sign In with Google") {
                    googleSignIn()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.48, green: 0.41, blue: 0.95))
                .foregroundColor(.white)
                .border(Color.gray, width: 2)
                .cornerRadius(4)
                .padding(100)
                .offset(y: -128)
                
                
                //Sign up button
                NavigationLink("Don't have an account? Sign Up!") {
                    signUpScreen
                }.padding()
                    .font(.system(size: 17, weight: .bold))
                    .underline(true, color: .blue)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .offset(y: -199)
                
                
                .padding(.horizontal, 20)
                Spacer()
                .frame(width: 350)
                
                .onAppear {
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            userIsLoggedIn.toggle()
                        }
                    }
                }
}
            .background(Color.black)
            .edgesIgnoringSafeArea(.all) // Make the background cover the entire screen
        }
    }
    
    func login() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                // Handle successful login
                userIsLoggedIn = true  // Update login state
                print("User logged in successfully")
            }
        }
    
    func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first!.rootViewController!) { result, error in
            guard error == nil else {
                print("Google Sign-In error: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase Sign-In error: \(error.localizedDescription)")
                    return
                }
                
                userIsLoggedIn = true
                print("User signed in with Google successfully")
            }
        }
    }
}

// SIGNUP PAGE
struct SignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    
    var body: some View {
        
        
        ZStack {
            Color.black // background color to black
            
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 330)
                    .padding(.top, -255)
                
                Text("Sign Up")
                    .foregroundColor(.white)
                    .offset(y: -35)
                    .font(.system(size: 31, weight: .bold))
                
                // Sign-up form UI elements
                TextField("New Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
                    .cornerRadius(2)
                    .padding(.bottom, 8)
                
                SecureField("New Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .border(Color(red: 123/255, green: 106/255, blue: 244/255), width: 0.6)
                    .cornerRadius(2)
                    .padding(.bottom, 8)
                
                // Display error message if any
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 15)
                }
                
                Button("Sign Up") {
                    signUp()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.48, green: 0.41, blue: 0.95))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 115)
                .offset(y: 45)
            }
            .padding()
            .foregroundColor(.white) // Set the text color to white for contrast
        }
        .edgesIgnoringSafeArea(.all)  // Ensures the background covers the entire screen
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }
    
    func signUp() {
        
        //might need to be an optional value in the future
        guard password != "" else {
            errorMessage = "Passwords do not match."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(firstName) \(lastName)"
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("Error saving name: \(error.localizedDescription)")
                } else {
                    print("Name saved successfully!")
                }
            }
            
            print("User signed up successfully.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview for ContentView (Login)
            ContentView()
            
            // Preview for SignUpView
            SignUpView()
        }
    }
}
