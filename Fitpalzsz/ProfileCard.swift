//
//  ProfileCard.swift
//  Fitpalzsz
//
//  Created by Joel Urena on 5/20/25.

import SwiftUI
//

struct ProfileCard: View {
    let user: UserModel  // or FriendStore.currentUser passed in
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: Profile image and username
            HStack(spacing: 16) {
                // Profile Image (placeholder)
                Image(systemName: "person.circle.fill")
                    .resizable().frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                // Username and level info
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title2).foregroundColor(.white)
                    Text("Level \(levelForXP(user.totalXP)) • \(user.totalXP) XP")
                        .font(.subheadline).foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            
            // Progress bar to next level
            let progressPercent = percentToNextLevel(for: user.totalXP)
            ProgressView(value: progressPercent, total: 100)
                .accentColor(Color("PurpleAccent"))  // or .tint(Color(red:0.48, green:0.42, blue:0.96))
                .foregroundColor(Color.purple)
                .frame(height: 8)
                .padding(.trailing, 16)
            
            // Achievements and Badges count
            let achievementsCount = user.unlockIDs.filter { id in
                XPSystem.shared.gallery.achievements.contains(where: {$0.id == id})
            }.count
            let badgesCount = user.unlockIDs.filter { id in
                XPSystem.shared.gallery.badges.contains(where: {$0.id == id})
            }.count
            Text("Achievements: \(achievementsCount)  |  Badges: \(badgesCount)")
                .font(.footnote).foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.gray.opacity(0.2).blendMode(.overlay)) // placeholder card bg
        .cornerRadius(12)
    }
}
