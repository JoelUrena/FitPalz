import SwiftUI
import FirebaseAuth

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        (r, g, b) = (
            (int >> 16) & 0xFF,
            (int >> 8) & 0xFF,
            int & 0xFF
        )
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}



struct HomeView: View {
    @State private var expandedStat: String? = nil
    @State private var isPulsing = false
    @Binding var userIsLoggedIn: Bool
    @State private var stepCount = 0
    @EnvironmentObject private var healthkitEngine: HealthkitEngine
    @EnvironmentObject var friendStore: FriendStore   // provides currentUser profile card
    
    
    let statsData: [StatItem] = [
        StatItem(label: "Calories Burned", value: "", icon: "flame.fill", details: "You burned 0.0 kcal today! Keep up the good work!", type: statType.caloriesBurned),
        StatItem(label: "Steps Taken", value: "", icon: "figure.walk.motion", details: "You’ve taken 0.0 steps! That’s an amazing effort!",type: statType.stepCount),
        StatItem(label: "Distance", value: "7.2 miles", icon: "shoeprints.fill", details: "You covered 0.0 miles today. Stay active!",type: statType.distance),
        StatItem(label: "Challenges", value: "30% complete", icon: "trophy", details: "You’ve completed 30% of your challenges. Keep pushing forward!", type: .none),
        StatItem(label: "Sleep", value: "40 hours", icon: "bed.double.fill", details: "You’ve accumulated 40 hours of sleep this week. Aim for consistency!", type: statType.sleep)
        
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image("fitpalz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 30)
                    
                    Text("Welcome Back!")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                    
                    // Profile snapshot (PSN‑style card)
                    ProfileCard(user: friendStore.currentUser)
                    
                    ForEach(statsData, id: \.label) { stat in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: stat.icon)
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .scaleEffect(isPulsing ? 1.1 : 1.0) // Pulse effect
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isPulsing)
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: "7b6af4"))
                                    .clipShape(Circle())
                                
                                
                                Text("\(stat.label): \(healthkitEngine.getData(forType: stat.type))")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            if expandedStat == stat.label {
                                Text(stat.details)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.7))
                                .shadow(color: Color.purple.opacity(0.3), radius: 5)
                        )
                        .scaleEffect(expandedStat == stat.label ? 1.03 : 1.0)
                        .animation(.spring(), value: expandedStat)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                expandedStat = (expandedStat == stat.label) ? nil : stat.label
                            }
                        }
                    }
                }
                
                .padding()
                .padding(.bottom, 40)
                .onAppear {
                    isPulsing = true
                }
                
            }
            .background(Color(hex: "191919").edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.white)
                            .accessibilityLabel("Sign Out")
                    }
                }
            }
            .task {
                
                //MARK: - this is how data is accessed from the healthkit class. The sleep metric is in second so we'll have to convert it to hours or minutes depending on what we need exactly
                
                print(healthkitEngine.lifeTimeStepCount)
                print(healthkitEngine.sleepTimePreviousNight/3600)
                print(healthkitEngine.lifetimeCaloriesBurned)
                print("Time in daylight: \(healthkitEngine.timeinDaylightToday)")
                print(healthkitEngine.lifetimeFlightsClimbed)
                
                
                
            }
            
        }
    }
    
    //google sign out
    func signOut() {
        do {
            try Auth.auth().signOut()  // Sign the user out from Firebase
            userIsLoggedIn = false     // Update the login state to false
            
            // Navigate back to the login/signup screen
            // We don't need to explicitly handle navigation in this view
            // because the `userIsLoggedIn` state in ContentView controls it
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
}

//enum to make it easier to determine between stat types
enum statType {
    
    case stepCount
    case caloriesBurned
    case distance
    case sleep
    case none
    
    
}

struct StatItem {
    let label: String
    let value: String
    let icon: String
    let details: String
    let type: statType
    
}

#Preview {
    HomeView(userIsLoggedIn: .constant(true))
}

