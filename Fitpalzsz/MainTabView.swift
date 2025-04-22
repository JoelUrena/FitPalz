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
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }

            FriendsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Friends")
                }
        }
    }
}
