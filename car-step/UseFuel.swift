//
//  UseFuel.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI

struct PartSVG: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.31944*width, y: 0.79759*height))
        path.addLine(to: CGPoint(x: 0.49079*width, y: 0.61982*height))
        path.addLine(to: CGPoint(x: 0.67056*width, y: 0.79759*height))
        path.addLine(to: CGPoint(x: 0.74079*width, y: 0.74482*height))
        path.addLine(to: CGPoint(x: 0.62843*width, y: 0.54204*height))
        path.addLine(to: CGPoint(x: 0.83629*width, y: 0.43093*height))
        path.addLine(to: CGPoint(x: 0.81382*width, y: 0.34759*height))
        path.addLine(to: CGPoint(x: 0.58348*width, y: 0.38926*height))
        path.addLine(to: CGPoint(x: 0.53573*width, y: 0.14759*height))
        path.addLine(to: CGPoint(x: 0.45146*width, y: 0.14759*height))
        path.addLine(to: CGPoint(x: 0.41494*width, y: 0.38093*height))
        path.addLine(to: CGPoint(x: 0.1818*width, y: 0.34204*height))
        path.addLine(to: CGPoint(x: 0.1509*width, y: 0.42537*height))
        path.addLine(to: CGPoint(x: 0.36719*width, y: 0.54204*height))
        path.addLine(to: CGPoint(x: 0.25764*width, y: 0.74482*height))
        path.addCurve(to: CGPoint(x: 0.49079*width, y: 0.14759*height), control1: CGPoint(x: -0.00921*width, y: 0.44481*height), control2: CGPoint(x: 0.25226*width, y: 0.13709*height))
        path.addCurve(to: CGPoint(x: 0.70752*width, y: 0.76982*height), control1: CGPoint(x: 0.91624*width, y: 0.16633*height), control2: CGPoint(x: 0.90611*width, y: 0.61982*height))
        path.addCurve(to: CGPoint(x: 0.26045*width, y: 0.75037*height), control1: CGPoint(x: 0.5993*width, y: 0.85156*height), control2: CGPoint(x: 0.41908*width, y: 0.90939*height))
        path.addLine(to: CGPoint(x: 0.16775*width, y: 0.85871*height))
        path.addCurve(to: CGPoint(x: 0.81382*width, y: 0.1087*height), control1: CGPoint(x: 0.58348*width, y: 1.28371*height), control2: CGPoint(x: 1.34472*width, y: 0.61982*height))
        path.addCurve(to: CGPoint(x: 0.16213*width, y: 0.85593*height), control1: CGPoint(x: 0.46769*width, y: -0.2163*height), control2: CGPoint(x: -0.33786*width, y: 0.25593*height))
        return path
    }
}

struct UseFuel: View {
    var fuel: Fuel
    var part: Part
    var onClose: () -> Void
    
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @State private var amountOfFuelUse: Int = 0
    @State private var useFuelState: String = "AmountPicking"
    
    @State private var partProgress: Double = 0
    
    @State private var createdPartName: String = ""
    @State private var createdPartType: String = ""
    @State private var createdPartRarity: String = ""
    
    var body: some View {
        if useFuelState == "AmountPicking" {
            VStack {
                HStack{
                    ZStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20))
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(90)
                    Text("\(fuel.value)")
                }
                Text("How mutch Fuel do you wanne use?")
                Text("\(amountOfFuelUse)")
                .multilineTextAlignment(.center)
                .font(.title)
                
                let minValue = 0
                let maxValue = part.maxValue - part.progressValue
                
                HStack {
                    Button("-1%") {
                        amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 100)
                    }
                    .disabled(amountOfFuelUse - fuel.value / 100 < 0)
                    .buttonStyle(.bordered)
                    Button("-10%") {
                        amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 10)
                    }
                    .disabled(amountOfFuelUse - fuel.value / 10 < 0)
                    .buttonStyle(.bordered)
                    Button("+10%") {
                        amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 10)
                    }
                    .buttonStyle(.bordered)
                    .disabled(amountOfFuelUse >= min(fuel.value, part.maxValue - part.progressValue))
                    Button("+1%") {
                        amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 100)
                    }
                    .buttonStyle(.bordered)
                    .disabled(amountOfFuelUse >= min(fuel.value, part.maxValue - part.progressValue))
                }
                HStack {
                    Button("Min") {
                        amountOfFuelUse = 1
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(amountOfFuelUse <= 1)
                    Button("Max") {
                        amountOfFuelUse = min(fuel.value, part.maxValue - part.progressValue)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(amountOfFuelUse == part.maxValue - part.progressValue)
                }
                Button("Start") {
                    useFuelState = "Running"
                    
                    let newPartProgress = Double(part.progressValue + amountOfFuelUse) / Double(part.maxValue)
                    withAnimation(.linear(duration: max(3.0, Double(amountOfFuelUse) / 500.0))) {
                        partProgress = newPartProgress
                    } completion: {
                        appData.updateFuel(fuel: fuel, context: context, newValue: fuel.value - amountOfFuelUse)
                        if partProgress == 1.0 {
                            createdPartName = part.name
                            createdPartType = part.type
                            createdPartRarity = part.rarity
                            
                            useFuelState = "ShapeDone"
                            appData.finishedPart(part: part, context: context)
                        } else {
                            useFuelState = "ShapeNotDone"
                            appData.updatePartProgrss(part: part, context: context, newValue: part.progressValue + amountOfFuelUse)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
                .disabled(amountOfFuelUse == 0)
            }
            .onAppear {
                partProgress = Double(part.progressValue) / Double(part.maxValue)
            }
        } else if useFuelState == "Running" {
            VStack {
                Spacer()
                part.getPartShape(neededPart: part.type, progress: partProgress, size: 300)
                Spacer()
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 300, height: 300)
        }
        if useFuelState == "ShapeDone" {
            Text("You have completed a part!")
                .font(.title)
            Text("\(part.name) has been added to you collection")
            VStack {
                Text("Name: \(createdPartName)")
                Text("Type: \(createdPartType)")
                Text("Rarity: \(createdPartRarity)")
            }
            Button("Back to Home"){
                onClose()
            }
        } else if useFuelState == "ShapeNotDone" {
            Text("Not Done")
            Button("Back to Home"){
                onClose()
            }
        }
    }
}

#Preview {
    let mockPart = Part(name: "Sparky", type: "Wheel", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now)
    let mockFuel = Fuel(value: 8000)
    UseFuel(fuel: mockFuel, part: mockPart, onClose: {})
}
