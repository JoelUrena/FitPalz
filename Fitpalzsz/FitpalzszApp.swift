

import SwiftUI
import HealthKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct FitpalzszApp: App {
    
    // Firebase delegate adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Shared FriendStore
    @StateObject private var friendStore = FriendStore()

    // HealthKit
    private let healthStore: HKHealthStore
    
    @StateObject private var healthkitEngine = HealthkitEngine()
    
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
        
        //The healthkit stuff should happen here. That way it is ready by the time the app gets to the homescreen
        healthkitEngine.readStepCountToday()
        healthkitEngine.readCaloiresBurnedToday()
        healthkitEngine.readWalkingandRunningDistanceToday()
        
        
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
                .environmentObject(friendStore).environmentObject(healthkitEngine)
        }
    }  
}
