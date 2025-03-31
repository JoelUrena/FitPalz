import SwiftUI

struct HomeView: View {
    @State private var expandedStat: String? = nil
    @State private var isPulsing = false

    let statsData: [StatItem] = [
        StatItem(label: "Calories Burned", value: "1200", icon: "flame.fill", details: "You burned 1200 kcal today! Keep up the good work!"),
        StatItem(label: "Steps Taken", value: "10,500", icon: "figure.walk.motion", details: "You’ve taken 10,500 steps! That’s an amazing effort!"),
        StatItem(label: "Distance", value: "7.2 miles", icon: "shoeprints.fill", details: "You covered 7.2 miles today. Stay active!"),
        StatItem(label: "Challenges", value: "30% complete", icon: "trophy", details: "You’ve completed 30% of your challenges. Keep pushing forward!"),
        StatItem(label: "Sleep", value: "40 hours", icon: "bed.double.fill", details: "You’ve accumulated 40 hours of sleep this week. Aim for consistency!")
       

    ]

    var body: some View {
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

                            Text("\(stat.label): \(stat.value)")
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
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct StatItem {
    let label: String
    let value: String
    let icon: String
    let details: String
}

