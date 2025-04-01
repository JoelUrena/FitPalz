import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var expandedStat: String? = nil
    @State private var isPulsing = false
    @State private var userIsLoggedIn = false
    @State private var stepCount = 0
    @StateObject var healthkitEngine = HealthkitEngine.shared
    
    let contentView = ContentView()

    let statsData: [StatItem] = [
        StatItem(label: "Calories Burned", value: "", icon: "flame.fill", details: "You burned 0.0 kcal today! Keep up the good work!", type: statType.caloriesBurned),
        StatItem(label: "Steps Taken", value: "", icon: "figure.walk.motion", details: "You’ve taken 0.0 steps! That’s an amazing effort!",type: statType.stepCount),
        StatItem(label: "Distance", value: "7.2 miles", icon: "shoeprints.fill", details: "You covered 0.0 miles today. Stay active!",type: statType.distance),
        StatItem(label: "Challenges", value: "30% complete", icon: "trophy", details: "You’ve completed 30% of your challenges. Keep pushing forward!", type: .none),
        StatItem(label: "Sleep", value: "40 hours", icon: "bed.double.fill", details: "You’ve accumulated 40 hours of sleep this week. Aim for consistency!", type: .none)
       
    ]

    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.top, 30)

                    Text("Welcome Back!")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                    
                    NavigationLink("Sign Out") {
                        contentView
                        
                    }.onDisappear {
                        signOut()
                    }.padding()
                        .font(.system(size: 17, weight: .bold))
                        .underline(true, color: .blue)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        

                    ForEach(statsData, id: \.label) { stat in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: stat.icon)
                                    .font(.title)
                                    .foregroundColor(.purple)
                                    .scaleEffect(isPulsing ? 1.1 : 1.0) // Pulse effect
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isPulsing)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black)
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
                        .background(expandedStat == stat.label ? Color.purple : Color.black.opacity(0.7))
                        .cornerRadius(12)
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
            
        }.background(Color.black.edgesIgnoringSafeArea(.all))
        
        }.task {
            
            healthkitEngine.readStepCountToday()
            healthkitEngine.readCaloiresBurnedToday()
            healthkitEngine.readWalkingandRunningDistanceToday()
            
            //it should create a stat item in here and THEN amend it to the array
            
            
            
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
    HomeView()
}

