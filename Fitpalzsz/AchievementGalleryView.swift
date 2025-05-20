//
//  Achievement_Gallery.swift
//  Fitpalzsz
//
//  Created by Joel Urena on 5/20/25.
//

// MARK: - Row Views
import SwiftUI

//helpers for color
// Color from hex string (e.g. "191919")
extension Color {
    init(hex: String) {
        let v = Int(hex, radix: 16) ?? 0
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8)  & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// Simple History button placeholder
struct HistoryButton: View {
    var body: some View {
        Button("History") {
            // TODO: navigate to ATS
        }
        .foregroundColor(.white)
    }
}

// Earn‑date lookup
extension UserModel {
    func earnedDate(for id: String) -> Date? {
        history.first(where: { $0.id == id })?.date
    }
}

// Helper to format the earned date nicely (e.g. “May 7, 2025”)
private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

/// Row for a single Achievement
struct AchievementRow: View {
    let achievement: AchievementNode
    let earnedDate: Date?        // nil if not yet earned
    
    var body: some View {
        HStack(spacing: 16) {
            // Placeholder icon (replace with Image(achievement.assetName) when assets are in XCAssets)
            Image(systemName: "rosette")
                .resizable()
                .frame(width: 40, height: 40)
                .opacity(earnedDate == nil ? 0.5 : 1.0)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .foregroundColor(.white)
                Text("XP: \(achievement.baseXP)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                if let earned = earnedDate {
                    Text("Earned \(dateFormatter.string(from: earned))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// Row for a single Badge
struct BadgeRow: View {
    let badge: BadgeNode
    let earnedDate: Date?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "seal.fill")      // placeholder
                .resizable()
                .frame(width: 40, height: 40)
                .opacity(earnedDate == nil ? 0.5 : 1.0)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .foregroundColor(.white)
                Text("Tier: \(badge.tier.rawValue)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                if let earned = earnedDate {
                    Text("Earned \(dateFormatter.string(from: earned))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AchievementGalleryView: View {
    @EnvironmentObject var friendStore: FriendStore
    @StateObject private var xpSystem = XPSystem.shared   // or injected
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ProfileCard(user: friendStore.currentUser)
                List {
                    // Achievements
                    Section(header: Text("Achievements").foregroundColor(.white)) {
                        ForEach(xpSystem.gallery.achievements.sorted(by: { $0.name < $1.name })) { ach in
                            AchievementRow(
                                achievement: ach,
                                earnedDate: friendStore.currentUser.earnedDate(for: ach.id)
                            )
                        }
                    }
                    // Badges
                    Section(header: Text("Badges").foregroundColor(.white)) {
                        ForEach(xpSystem.gallery.badges.sorted(by: { $0.name < $1.name })) { badge in
                            BadgeRow(
                                badge: badge,
                                earnedDate: friendStore.currentUser.earnedDate(for: badge.id)
                            )
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                    
            }
            .background(Color(hex: "191919"))
            .toolbar { HistoryButton() }
            .navigationTitle("Achievements")
        }
    }
}
