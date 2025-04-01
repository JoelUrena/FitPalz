//
//  FitpalzszApp.swift
//  Fitpalzsz
//
//  Created by Naomi Talukder on 3/24/25.
//

import SwiftUI
import HealthKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct FitpalzszApp: App {
    
    //firebase config
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
    }
    
    //google sign in
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    //healthkit initialization
    private let healthStore: HKHealthStore
    
    init() {
        
        //make sure that there is actual data in this thing
        guard HKHealthStore.isHealthDataAvailable() else {
            
            fatalError("no health data available")
            
        }
        
        healthStore = HKHealthStore()
        requestHealthKitAccess()
        
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
    
    //healthkit permissions
    private func requestHealthKitAccess() {
        
        let samples = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!,HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,HKObjectType.quantityType(forIdentifier:  .activeEnergyBurned)!])
        
        healthStore.requestAuthorization(toShare: nil, read: samples) { success, error in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }  
}
