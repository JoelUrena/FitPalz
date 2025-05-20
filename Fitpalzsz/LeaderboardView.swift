import SwiftUI
import FirebaseFirestore


// Leaderboard Model
// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Comparable {
    let id: UUID = UUID()
    let name: String
    let xp: Int
    let badges: Int
    let achievements: Int
    let profileImage: String
    
    // Comparable conformance for sorting (higher XP first)
    static func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
        lhs.xp > rhs.xp   // reverse order for descending

    }
}

final class LeaderboardStore: ObservableObject {
    @Published var top10AllTime: [LeaderboardEntry] = []
    @Published var top10Weekly: [LeaderboardEntry] = []
    @Published var allWeeklyEntries: [LeaderboardEntry] = []
    @Published var allAllTimeEntries: [LeaderboardEntry] = []
    
    private var hasLoadedAllTime = false
    private var hasLoadedWeekly = false

    func loadLeaderboard(isWeekly: Bool) async {
        if isWeekly && !hasLoadedWeekly {
            let entries = await Self.fetchTopUsers(weekly: true)
            top10Weekly = Array(entries.prefix(10))
            allWeeklyEntries = entries
            hasLoadedWeekly = true
        } else if !isWeekly && !hasLoadedAllTime {
            let entries = await Self.fetchTopUsers(weekly: false)
            top10AllTime = Array(entries.prefix(10))
            allAllTimeEntries = entries
            hasLoadedAllTime = true
        }
    }

    static func fetchTopUsers(limit: Int = 10, weekly: Bool = false) async -> [LeaderboardEntry] {
        let db = Firestore.firestore()
        var entries: [LeaderboardEntry] = []

        do {
            if weekly {
                let weekKey = getWeekKey(for: Date())
                let snapshot = try await db.collectionGroup("weeklyXP")
                    .whereField("weekId", isEqualTo: weekKey)
                    .order(by: "xp", descending: true)
                    .limit(to: limit)
                    .getDocuments()

                for doc in snapshot.documents {
                    let userId = doc.reference.parent.parent!.documentID
                    let userDoc = try await db.collection("users").document(userId).getDocument()
                    let userData = userDoc.data() ?? [:]
                    let name = userData["firstName"] as? String ?? "Unknown"
                    let xp = doc.data()["xp"] as? Int ?? 0

                    let unlockSnap = try await db.collection("users").document(userId).collection("unlocks").getDocuments()
                    let unlockIDs = unlockSnap.documents.map { $0.documentID }

                    let badgeCount = unlockIDs.filter { id in
                        XPSystem().gallery.badges.contains(where: { $0.id == id })
                    }.count

                    let achievementCount = unlockIDs.filter { id in
                        XPSystem().gallery.achievements.contains(where: { $0.id == id })
                    }.count

                    entries.append(LeaderboardEntry(
                        name: name,
                        xp: xp,
                        badges: badgeCount,
                        achievements: achievementCount,
                        profileImage: "person.circle"
                    ))
                }

            } else {
                let snapshot = try await db.collection("users")
                    .order(by: "totalXP", descending: true)
                    .limit(to: limit)
                    .getDocuments()

                for doc in snapshot.documents {
                    let data = doc.data()
                    let name = data["firstName"] as? String ?? "Unknown"
                    let xp = data["totalXP"] as? Int ?? 0
                    let uid = doc.documentID

                    let unlockSnap = try await db.collection("users").document(uid).collection("unlocks").getDocuments()
                    let unlockIDs = unlockSnap.documents.map { $0.documentID }

                    let badgeCount = unlockIDs.filter { id in
                        XPSystem().gallery.badges.contains(where: { $0.id == id })
                    }.count

                    let achievementCount = unlockIDs.filter { id in
                        XPSystem().gallery.achievements.contains(where: { $0.id == id })
                    }.count

                    entries.append(LeaderboardEntry(
                        name: name,
                        xp: xp,
                        badges: badgeCount,
                        achievements: achievementCount,
                        profileImage: "person.circle"
                    ))
                }
            }

            return entries.sorted()

        } catch {
            print("Error loading leaderboard: \(error)")
            return []
        }
    }
}

private struct LBRow: View {
    let rank: Int
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 16) {
            Text(rankIcon(for: rank - 1))
                .font(.title2)
                .foregroundColor(rankColor(for: rank - 1))
                .frame(width: 40, alignment: .leading)

            Image(systemName: entry.profileImage)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .background(Circle().fill(Color(hex: "7b6af4")).frame(width: 50, height: 50))
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .foregroundColor(.white)
                    .font(.headline)
                Text("XP: \(entry.xp)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
                .shadow(color: Color.purple.opacity(0.3), radius: 5)
        )
    }
    func rankIcon(for index: Int) -> String {
            switch index {
            case 0: return "🥇"
            case 1: return "🥈"
            case 2: return "🥉"
            default: return "#\(index + 1)"
            }
        }

        func rankColor(for index: Int) -> Color {
            switch index {
            case 0: return .yellow
            case 1: return .gray
            case 2: return .orange
            default: return .white
            }
        }
    }


//Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var friendStore: FriendStore
    @StateObject private var store = LeaderboardStore()
    @State private var showWeekly = false
    
    // Change currentFriends to be a state variable
    @State private var currentFriends: [LeaderboardEntry] = []

    var body: some View {
        ZStack {
            Color(hex: "191919").edgesIgnoringSafeArea(.all)

            NavigationView {
                VStack(spacing: 12) {
                    Picker("Mode", selection: $showWeekly) {
                        Text("Weekly").tag(true)
                        Text("All‑Time").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    List {
                        Section("Top 10") {
                            ForEach(currentTop10.indices, id: \.self) { i in
                                LBRow(rank: i + 1, entry: currentTop10[i])
                                    .listRowBackground(Color.clear)
                            }
                        }

                        Section("Your Rank") {
                            LBRow(rank: userRank, entry: currentUserEntry)
                                .foregroundStyle(.yellow)
                                .listRowBackground(Color.clear)
                        }

                        if !currentFriends.isEmpty {
                            Section("Your Friends") {
                                ForEach(currentFriends.indices, id: \.self) { i in
                                    LBRow(rank: friendRanks[i], entry: currentFriends[i])
                                        .listRowBackground(Color.clear)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
                .background(Color(hex: "191919"))
                .navigationTitle("Leaderboard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
        .onAppear {
            Task {
                await store.loadLeaderboard(isWeekly: showWeekly)
                await fetchFriends()
            }
        }
        .task(id: showWeekly) {
            await store.loadLeaderboard(isWeekly: showWeekly)
        }
    }


    // Helpers to pick weekly/all‑time arrays
    private var currentTop10: [LeaderboardEntry] {
        showWeekly ? store.top10Weekly : store.top10AllTime
    }

    private var currentUserEntry: LeaderboardEntry {
        let current = friendStore.currentUser
        return LeaderboardEntry(
            name: "You",
            xp: current.totalXP,
            badges: current.unlockIDs.filter { id in
                XPSystem().gallery.badges.contains(where: { $0.id == id })
            }.count,
            achievements: current.unlockIDs.filter { id in
                XPSystem().gallery.achievements.contains(where: { $0.id == id })
            }.count,
            profileImage: "person.circle"  // This should be dynamic if available
        )
    }

    private var userRank: Int {
        guard let userId = friendStore.currentUser.uid, let userUUID = UUID(uuidString: userId) else {
            // Handle the case where UID is not available or not valid
            return -1
        }

        // Find the rank (position) of the current user in the leaderboard
        let rank = currentTop10.firstIndex { entry in
            entry.id == userUUID  // Now we're comparing two UUID values
        } ?? -1  // Return -1 if the user is not found in the leaderboard
        return rank + 1  // Return the rank as 1-based index
    }

    private var friendRanks: [Int] {
        currentFriends.enumerated().map { idx, _ in idx + 1 }
    }

    // Fetch friends and their ranks
    private func fetchFriends() async {
        let friends = await entries(from: friendStore)
        self.currentFriends = friends.sorted()
    }
}

// Helper to get leaderboard entries from friends
private func entries(from friendStore: FriendStore) async -> [LeaderboardEntry] {
    await MainActor.run {
        return friendStore.friends.map { friend in
            LeaderboardEntry(
                name: friend.contact.name,
                xp: friend.user.totalXP,
                badges: friend.user.unlockIDs.filter { id in
                    XPSystem().gallery.badges.contains(where: { $0.id == id })
                }.count,
                achievements: friend.user.unlockIDs.filter { id in
                    XPSystem().gallery.achievements.contains(where: { $0.id == id })
                }.count,
                profileImage: "person.circle"  // This should be dynamic if available
            )
        }
    }
}

/// Returns a string like "2025-W21" for the given date
func getWeekKey(for date: Date) -> String {
    let calendar = Calendar(identifier: .iso8601)
    let week = calendar.component(.weekOfYear, from: date)
    let year = calendar.component(.yearForWeekOfYear, from: date)
    return "\(year)-W\(week)"
}

// MARK: - Preview
#if DEBUG
struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        let friendStore = FriendStore()
        LeaderboardView()
            .environmentObject(friendStore)
            .previewDisplayName("Leaderboard")
    }
}
#endif
 

 
