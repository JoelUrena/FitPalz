//
//  testApp.swift
//  test

import SwiftUI
import Firebase


//class AppDelegate: UIResponder, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

@main
struct testApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
