//
//  SevenDaysGraphic.swift
//  car-step
//
//  Created by Maxim Tampere on 25/01/2026.
//

import SwiftUI

struct SevenDaysGraphic: View {
    var days: [Day]
    
    @State private var lastSevenDays: [Day] = []
    @State private var lastSevenDaysTotalSteps: Int = 0
    @State private var lastSevenDaysTotalFuelUsed: Int = 0
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Last 7 Days")
            
            HStack {
                Text("Total steps: \(lastSevenDaysTotalSteps)")
                Text("Total fuel used: \(lastSevenDaysTotalFuelUsed)")
            }
            
            ForEach(lastSevenDays, id: \.self) { day in
                HStack {
                    VStack {
                        Text("Total steps: \(day.totalSteps)")
                        Text("Total fuel used: \(day.usedFuel)")
                    }
                    Spacer()
                    Text(day.date.formatted(date: .abbreviated, time: .omitted))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color("PrimaryAppColor"))
                .background(Color.gray)
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("PrimaryAppColor"))
        .cornerRadius(12)
        .onAppear {
            lastSevenDaysTotalSteps = lastSevenDays.reduce(0) { $0 + $1.totalSteps }
            lastSevenDaysTotalFuelUsed = lastSevenDays.reduce(0) { $0 + $1.usedFuel }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            let pastSevenDays: [Date] = (0..<7).map { i in
                calendar.date(byAdding: .day, value: -i, to: today)!
            }

            lastSevenDays = pastSevenDays.map { date in
                if let existingDay = days.first(where: { calendar.isDate($0.date, inSameDayAs: date)}) {
                    return existingDay
                } else {
                    return Day(id: UUID(), userId: UUID(), date: date, totalSteps: 0, claimedSteps: 0, usedFuel: 0)
                }
            }

        }
    }
}

#Preview {
    //SevenDaysGraphic()
}
