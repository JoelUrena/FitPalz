

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
        // Ensure health data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("no health data available")
        }
        
        healthStore = HKHealthStore()
        requestHealthKitAccess()

        // Tab Bar appearance customization
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray

        // Segmented Control text color fix
        let purple = UIColor(red: 123/255, green: 106/255, blue: 244/255, alpha: 1.0) // match your icon purple
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        // Unselected state
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.lightGray,
            .font: font
        ], for: .normal)

        // Selected state
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: purple,
            .font: font
        ], for: .selected)

        // fix background flicker by setting selected segment tint
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(white: 0.15, alpha: 1.0) // dark gray


        
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
            ContentView()
                .environmentObject(friendStore).environmentObject(HealthkitEngine.shared)
        }
    }
}
