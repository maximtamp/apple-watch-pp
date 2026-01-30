//
//  SevenDaysGraphic.swift
//  car-step
//
//  Created by Maxim Tampere on 25/01/2026.
//

import SwiftUI
import Charts

struct SevenDaysGraphic: View {
    var days: [Day]

    @State private var lastSevenDays: [Day] = []
    @State private var lastSevenDaysTotalSteps: Int = 0
    @State private var lastSevenDaysTotalFuelUsed: Int = 0
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Last 7 Days")
                .bold()
            
            Chart(days.sorted { $0.date < $1.date }) { day in
                LineMark(x: .value("Date", day.date), y: .value("TotalSteps", day.totalSteps))
                    .foregroundStyle(by: .value("Type", "TotalSteps (\(lastSevenDaysTotalSteps))"))
                    .symbol(by: .value("Type", "TotalSteps (\(lastSevenDaysTotalSteps))"))
                LineMark(x: .value("Date", day.date), y: .value("UsedFuel", day.usedFuel))
                    .foregroundStyle(by: .value("Type", "UsedFuel (\(lastSevenDaysTotalFuelUsed))"))
                    .symbol(by: .value("Type", "UsedFuel (\(lastSevenDaysTotalFuelUsed))"))
            }
            .aspectRatio(16/9, contentMode: .fit)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("PrimaryAppColor"))
        .cornerRadius(12)
        .onAppear {
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
            
            lastSevenDaysTotalSteps = lastSevenDays.reduce(0) { $0 + $1.totalSteps }
            lastSevenDaysTotalFuelUsed = lastSevenDays.reduce(0) { $0 + $1.usedFuel }
        }
    }
}

#Preview {
    //SevenDaysGraphic()
}
