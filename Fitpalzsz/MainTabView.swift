import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            LeaderboardView()
                .tabItem { Label("Leaderboard", systemImage: "trophy") }

//            FriendsListView()
//                .tabItem {
//                    Image(systemName: "person.2")
//                    Text("Friends")
//                }
            FindFriendsView()
                    .tabItem { Label("Find Friends", systemImage: "person.badge.plus") }

                FriendsListView()
                    .tabItem { Label("Friends", systemImage: "person.2") }
        }
    }
}
