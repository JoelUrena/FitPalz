//
//  AchievementHistoryView.swift
//  Fitpalzsz
//
//  Created by Joel Urena on 5/20/25.
//

//
//  AchievementHistoryView.swift
//  FitPalz
//
//  Shows a reverse‑chronological list of every achievement / badge the
//  current user has unlocked.
//  The most‑recent row is highlighted in yellow.
//

import SwiftUI

// MARK: - Date formatter
private let historyDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium     // “May 20, 2025”
    return df
}()

// MARK: - History Row
private struct HistoryRow: View {
    let record: UnlockRecord
    let isMostRecent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Fallback symbol; replace with Image(assetName) when icons exist
            iconImage
                .resizable()
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .foregroundColor(.white)
                Text(metaText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(isMostRecent ? Color.yellow.opacity(0.2) : Color.clear)
        .cornerRadius(8)
    }
    
    // Helpers to map the record.id to gallery data --------
    private var gallery: AchBadgeGallery { XPSystem.shared.gallery }
    
    private var isAchievement: Bool {
        gallery.achievements.contains(where: { $0.id == record.id })
    }
    
    private var displayName: String {
        if let a = gallery.achievements.first(where: { $0.id == record.id }) {
            return a.name
        }
        if let b = gallery.badges.first(where: { $0.id == record.id }) {
            return b.name
        }
        return record.id
    }
    
    private var metaText: String {
        let date = historyDateFormatter.string(from: record.date)
        if let a = gallery.achievements.first(where: { $0.id == record.id }) {
            return "XP: \(a.baseXP)  •  \(date)"
        }
        if let b = gallery.badges.first(where: { $0.id == record.id }) {
            return "Tier: \(b.tier.rawValue)  •  \(date)"
        }
        return date
    }
    
    private var iconImage: Image {
        if let a = gallery.achievements.first(where: { $0.id == record.id }) {
            return Image(a.assetName)          // assetName from JSON
        }
        if let b = gallery.badges.first(where: { $0.id == record.id }) {
            return Image(b.assetName)
        }
        // fallback system symbol
        return Image(systemName: isAchievement ? "rosette" : "seal.fill")
    }
}

// MARK: - Achievement History Screen
struct AchievementHistoryView: View {
    @EnvironmentObject var friendStore: FriendStore
    
    // Sorted newest → oldest
    private var records: [UnlockRecord] {
        friendStore.currentUser.history.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            ForEach(records.indices, id: \.self) { idx in
                HistoryRow(record: records[idx], isMostRecent: idx == 0)
                    .listRowBackground(Color(hex: "191919"))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "191919"))
        .navigationTitle("History")
    }
}

// MARK: - Preview
#if DEBUG
struct AchievementHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock a friendStore with one recent entry
        let store = FriendStore()
        var me = UserModel()
        me.username = "PreviewUser"
        me.totalXP = 1234
        me.unlockIDs = ["moonwalk-103k-steps"]
        me.history = [UnlockRecord(id: "moonwalk-103k-steps", date: Date())]
        store.currentUser = me
        
        return NavigationView {
            AchievementHistoryView()
                .environmentObject(store)
        }
        .previewDisplayName("Achievement History")
    }
}
#endif
