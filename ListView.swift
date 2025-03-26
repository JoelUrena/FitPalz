//
//  ListView.swift
//  test


import SwiftUI
import Firebase
import FirebaseAuth

struct ListView: View {
    @State private var userIsLoggedIn = false // Track login state
    
    var body: some View {
        NavigationView {
            VStack {
                // Sign Out Button at the top
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .background(Color.white)
                        .offset(y: 150)
                    
                }
                
                // Main content
                Text("HELLOOOO WORLD")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                    .offset(y: 250)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()  // Sign the user out from Firebase
            userIsLoggedIn = false     // Update the login state to false
            
            // Navigate back to the login/signup screen
            // We don't need to explicitly handle navigation in this view
            // because the `userIsLoggedIn` state in ContentView controls it
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
