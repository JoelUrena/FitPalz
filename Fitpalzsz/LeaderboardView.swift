import SwiftUI

// Leaderboard Model
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let profileImage: String
    let xpPoints: Int
}

// Sample Leaderboard Data (sorted by XP)
let leaderboardData = [
    LeaderboardEntry(name: "Jordan", profileImage: "person.circle", xpPoints: 2200),
    LeaderboardEntry(name: "Alex", profileImage: "person.circle", xpPoints: 1800),
    LeaderboardEntry(name: "Sam", profileImage: "person.circle", xpPoints: 1450),
    LeaderboardEntry(name: "Taylor", profileImage: "person.circle", xpPoints: 1000),
    LeaderboardEntry(name: "Morgan", profileImage: "person.circle", xpPoints: 800),
    LeaderboardEntry(name: "Riley", profileImage: "person.circle", xpPoints: 600)
]

// Leaderboard View
struct LeaderboardView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "191919").edgesIgnoringSafeArea(.all)
                
                VStack {
                    List(Array(leaderboardData.enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 16) {
                            Text(rankIcon(for: index))
                                .font(.title2)
                                .foregroundColor(rankColor(for: index))

                            Image(systemName: entry.profileImage)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .background(Circle().fill(Color(hex: "7b6af4")).frame(width: 50, height: 50))
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading) {
                                Text(entry.name)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text("XP: \(entry.xpPoints)")
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
                        .listRowBackground(Color.clear)
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

    // Medal emoji for top 3, rank number for others
    func rankIcon(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)"
        }
    }

    // Color medals differently
    func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .white
        }
    }
}

