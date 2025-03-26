//
//  testApp.swift
//  test

@main
struct testApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
