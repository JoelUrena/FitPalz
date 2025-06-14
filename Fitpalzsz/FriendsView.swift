import SwiftUI
import Contacts

func fetchContacts(completion: @escaping ([Friend]) -> Void) {
    let contactStore = CNContactStore()
    let keysToFetch: [CNKeyDescriptor] = [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor
    ]
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)

    var fetchedFriends: [Friend] = [] 

    do {
        try contactStore.enumerateContacts(with: request) { (contact, stop) in
            let fullName = "\(contact.givenName) \(contact.familyName)"
            let friend = Friend(
                name: fullName,
                profileImage: "person.circle",
                caloriesBurned: Int.random(in: 500...2000),
                stepsTaken: Int.random(in: 3000...15000),
                distanceWalked: Double.random(in: 1...10),
                challengesCompleted: Int.random(in: 10...100),
                sleepHours: Int.random(in: 20...50)
            )
            fetchedFriends.append(friend)
        }
        completion(fetchedFriends)
    } catch {
        print("Failed to fetch contacts, error: \(error)")
        completion([])
    }
} 

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



//Friends View
struct FriendsView: View {
    @State private var searchText: String = ""
    @State private var isAddFriendPresented = false
    @State private var expandedFriendID: UUID? = nil
    @State private var friends: [Friend] = [] 
    
    
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
       
        ZStack {
            Color(hex: "191919").edgesIgnoringSafeArea(.all)
                
            NavigationView {
                VStack(spacing: 12) { 
                    if filteredFriends.isEmpty {
                        ZStack{
                            Color(hex: "191919").edgesIgnoringSafeArea(.all)
                            VStack(spacing:12) {
                                Image(systemName: "person.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No friends yet")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Go to the Find Friend tab to add palz!")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "191919"))
                        .edgesIgnoringSafeArea(.all)
                    } else{
                        
                        List(filteredFriends) { friend in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 16) {
                                    Image(systemName: friend.profileImage)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color(hex: "7b6af4")).frame(width: 50, height: 50))
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
                                        .rotationEffect(.degrees(expandedFriendID == friend.id ? 180 : 0))
                                        .animation(.easeInOut(duration: 0.3), value: expandedFriendID)
                                }
                                
                                if expandedFriendID == friend.id {
                                    VStack(alignment: .leading, spacing: 10) {
                                        StatRow(icon: "flame.fill", label: "Calories Burned", value: "\(friend.caloriesBurned)")
                                        StatRow(icon: "shoeprints.fill", label: "Distance Walked", value: String(format: "%.1f miles", friend.distanceWalked))
                                        StatRow(icon: "trophy", label: "Challenges Completed", value: "\(friend.challengesCompleted)%")
                                        StatRow(icon: "bed.double.fill", label: "Sleep", value: "\(friend.sleepHours) hours this week")
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.7))
                                    .shadow(color: Color.purple.opacity(0.3), radius: 5)
                            )
                            .onTapGesture {
                                withAnimation {
                                    expandedFriendID = (expandedFriendID == friend.id) ? nil : friend.id
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        
                    }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .searchable(text: $searchText)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "191919"))
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                fetchContacts { fetched in
                    friends = fetched
                    
                }
            }

            
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
                .background(Color(hex: "191919"))
                .foregroundColor(.white)
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

