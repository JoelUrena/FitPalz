import SwiftUI


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

/// Fake data provider – replace later with Firebase fetch
final class LeaderboardStore: ObservableObject {
    @Published var top10AllTime: [LeaderboardEntry] = []
    @Published var top10Weekly: [LeaderboardEntry] = []
    
    // ───────── LeaderboardStore.init ─────────
    init() {
        // hard‑coded mock top‑10 for now
        let mockTop = (0..<10).map { i in
            LeaderboardEntry(name: "Top \(i + 1)",
                             xp: 100_000 - i * 5_000,
                             badges: 0,
                             achievements: 0,
                             profileImage: "person.circle")
        }
        top10AllTime = mockTop
        top10Weekly = mockTop.shuffled()
    }
    /// Converts FriendStore friends to LeaderboardEntry array
    @MainActor
    static func entries(from friendStore: FriendStore) -> [LeaderboardEntry] {
        friendStore.friends.map { f in
            LeaderboardEntry(
                name: f.contact.name,
                xp: f.user.totalXP,
                badges: f.user.unlockIDs.filter { id in
                    XPSystem().gallery.badges.contains(where: { $0.id == id })
                }.count,
                achievements: f.user.unlockIDs.filter { id in
                    XPSystem().gallery.achievements.contains(where: { $0.id == id })
                }.count,
                profileImage: "person.circle"
            )
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


// Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var friendStore: FriendStore
    @StateObject private var store = LeaderboardStore()
    @State private var showWeekly = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "191919").edgesIgnoringSafeArea(.all)
                
                VStack {
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
                            }
                            .navigationTitle("Leaderboard")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color.black, for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .toolbarColorScheme(.dark, for: .navigationBar)
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
            profileImage: "person.circle"
        )
    }
    private var currentFriends: [LeaderboardEntry] {
        LeaderboardStore.entries(from: friendStore)
            .sorted()
            .prefix(10)
            .map { $0 }
    }
    private var userRank: Int {
        // For mock demo, assume rank is 42 / 38
        showWeekly ? 39 : 43
    }
    private var friendRanks: [Int] {
        currentFriends.enumerated().map { idx, _ in idx + 1 }
    }
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
 
