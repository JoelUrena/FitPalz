//
//  FitpalzszApp.swift
//  Fitpalzsz
//
//  Created by Naomi Talukder on 3/24/25.
//

import SwiftUI 

@main
struct FitpalzszApp: App {
    init() {
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
