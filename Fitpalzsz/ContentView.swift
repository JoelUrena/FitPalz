import SwiftUI
import UIKit


// dummy page (use zayns code later)
struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            VStack(spacing: 20) {
                Text("Welcome to HealthBuddy")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 100)

                Button("Log In") {
                    isLoggedIn = true
                }
                .padding()
                .frame(width: 200)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black) // or Color.black for dark theme


        }
    }
}
