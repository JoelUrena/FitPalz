

import SwiftUI
import HealthKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AVKit

@main
struct FitpalzszApp: App {
    
    // Firebase delegate adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Shared FriendStore
    @StateObject private var friendStore = FriendStore()
    
    // HealthKit
    private let healthStore: HKHealthStore
    
    @StateObject private var healthkitEngine = HealthkitEngine()

    // Splash‑video flag
    @State private var showSplash = true
    
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
    
    init() {
        
        //make sure that there is actual data in this thing
        guard HKHealthStore.isHealthDataAvailable() else {
            
            fatalError("no health data available")
            
        }
        
        healthStore = HKHealthStore()
        requestHealthKitAccess()
        
        
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
        
        let samples = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!,HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,HKObjectType.quantityType(forIdentifier:  .activeEnergyBurned)!,HKObjectType.quantityType(forIdentifier:  .timeInDaylight)!,HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,HKObjectType.quantityType(forIdentifier: .flightsClimbed)!])
        
        healthStore.requestAuthorization(toShare: nil, read: samples) { success, error in
            
            //only read data if authorization is given
            if success {
                HealthkitEngine.shared.readAllData()
            }
            
            else {
                print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
            }
            
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                LaunchVideoView {
                    // dismiss splash when video finishes
                    showSplash = false
                }
            } else {
                ContentView()
                    .environmentObject(friendStore)
                    .environmentObject(HealthkitEngine.shared)
            }
        }
    }
}
