//
//  History.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData

struct History: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData

    @Query private var days: [Day]
    
    var body: some View {
        List(days, id: \.date) { day in
            HStack {
                Image(systemName: "calendar")
                    .font(.largeTitle)
                    .frame(width: 48, height: 48)
                    .padding(4)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                HStack(alignment: .top) {
                    VStack {
                        Text("Steps: \(day.totalSteps)")
                        Text("+Fuel: \(day.claimedSteps)")
                    }
                    .padding(.horizontal, 8)
                    Spacer()
                    Text(day.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.primary.opacity(0.6))
                }
            }
        }
        .refreshable {
            if let today = appData.today {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
            }
        }
        Button("Onboarding") {
            isOnboarding = true
        }
    }
}

#Preview {
    History()
}
