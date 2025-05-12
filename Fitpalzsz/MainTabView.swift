import SwiftUI

struct MainTabView: View {
    @Binding var userIsLoggedIn: Bool
    
    var body: some View {
        TabView {
            HomeView(userIsLoggedIn: $userIsLoggedIn)
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
