//
//  FitpalzszApp.swift
//  Fitpalzsz
//
//  Created by Naomi Talukder on 3/24/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct FitpalzszApp: App {
    
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    init() {
        
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
           let appearance = UITabBarAppearance()
           appearance.configureWithOpaqueBackground()
           appearance.backgroundColor = UIColor.black
           UITabBar.appearance().standardAppearance = appearance
           
           if #available(iOS 15.0, *) { // ios 14 or earlir will crash
               UITabBar.appearance().scrollEdgeAppearance = appearance
           }

           UITabBar.appearance().tintColor = UIColor.white
           UITabBar.appearance().unselectedItemTintColor = UIColor.gray
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }  
}
