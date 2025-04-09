import SwiftUI

// Friend Model
struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let profileImage: String
    let caloriesBurned: Int
    let stepsTaken: Int
    let distanceWalked: Double
    let challengesCompleted: Int
    let sleepHours: Int
}

// Sample Data
let sampleFriends = [
    Friend(name: "Alex", profileImage: "person.circle", caloriesBurned: 1200, stepsTaken: 10500, distanceWalked: 7.2, challengesCompleted: 30, sleepHours: 40),
    Friend(name: "Jordan", profileImage: "person.circle", caloriesBurned: 1600, stepsTaken: 14000, distanceWalked: 9.4, challengesCompleted: 50, sleepHours: 38),
    Friend(name: "Sam", profileImage: "person.circle", caloriesBurned: 800, stepsTaken: 6000, distanceWalked: 4.1, challengesCompleted: 20, sleepHours: 35)
]

//Friends View
struct FriendsView: View {
    @State private var searchText: String = ""
    @State private var isAddFriendPresented = false

    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return sampleFriends
        } else {
            return sampleFriends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    List(filteredFriends) { friend in
                        NavigationLink(destination: FriendDetailView(friend: friend)) {
                            HStack(spacing: 16) {
                                Image(systemName: friend.profileImage)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.purple).frame(width: 50, height: 50))
                                    .frame(width: 40, height: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(friend.name)
                                        .foregroundColor(.white)
                                        .font(.headline)

                                    Text("Steps: \(friend.stepsTaken)")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.7))
                                    .shadow(color: Color.purple.opacity(0.3), radius: 5)
                            )
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .searchable(text: $searchText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddFriendPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $isAddFriendPresented) {
                VStack {
                    Text("Add Friend Feature Coming Soon")
                        .font(.title2)
                        .padding()
                    Button("Close") {
                        isAddFriendPresented = false
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .foregroundColor(.white)
            }
        }
    }
}
// Friend Detail View
struct FriendDetailView: View {
    var friend: Friend

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: friend.profileImage)
                    .resizable()
                    .foregroundColor(.purple)
                    .frame(width: 100, height: 100)
                    .padding()

                Text(friend.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 15) {
                    StatRow(icon: "flame.fill", label: "Calories Burned", value: "\(friend.caloriesBurned)")
                    StatRow(icon: "figure.walk.motion", label: "Steps Taken", value: "\(friend.stepsTaken)")
                    StatRow(icon: "shoeprints.fill", label: "Distance Walked", value: String(format: "%.1f miles", friend.distanceWalked))
                    StatRow(icon: "trophy", label: "Challenges Completed", value: "\(friend.challengesCompleted)%")
                    StatRow(icon: "bed.double.fill", label: "Sleep", value: "\(friend.sleepHours) hours this week")
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

//  Stat Row Component
struct StatRow: View {
    var icon: String
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 25)
            Text("\(label): \(value)")
                .foregroundColor(.white)
                .font(.body)
        }
    }
}




