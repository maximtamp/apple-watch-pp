//
//  Garage.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct Garage: View {
    
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var parts: [Part]
    @Query private var cars: [Car]
    
    var rarityOrder = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
    
    var tabs = [
        (id: 1, name: "Body", icon: "car.fill"),
        (id: 2, name: "Engine", icon: "engine.combustion.fill"),
        (id: 3, name: "Wheel", icon: "tire"),
    ]
    
    var body: some View {
        if let car = appData.car {
            TabView {
                VStack{
                    if let bodyPart = parts.first(where: {$0.id == car.bodyId}) {
                        Text("Body: \(bodyPart.name)")
                    } else {
                        Text("Body: Not Selected")
                    }
                    
                    if let enginePart = parts.first(where: {$0.id == car.engineId}) {
                        Text("Engine: \(enginePart.name)")
                    } else {
                        Text("Engine: Not Selected")
                    }
                    
                    if let wheelPart = parts.first(where: {$0.id == car.wheelId}) {
                        Text("Wheels: \(wheelPart.name)")
                    } else {
                        Text("Wheels: Not Selected")
                    }
                }
                .background(car.getCarColor)
                
                ForEach(tabs, id: \.id) { tab in
                    ScrollView{
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: tab.icon)
                                Text(tab.name)
                            }
                            ForEach(
                                parts
                                    .filter {$0.type.lowercased() == tab.name.lowercased() && $0.partMade}
                                    .sorted{partA, partB in
                                        if partA.id == car.bodyId || partA.id == car.engineId || partA.id == car.wheelId {
                                            return true
                                        }
                                        if partB.id == car.bodyId || partB.id == car.engineId || partB.id == car.wheelId {
                                            return false
                                        }
                                        
                                        let rarityA = rarityOrder.firstIndex(of: partA.rarity) ?? 0
                                        let rarityB = rarityOrder.firstIndex(of: partB.rarity) ?? 0
                                        return rarityA > rarityB
                                    }
                            ) { part in
                                
                                Button {
                                    appData.updateCarPartId(car: car, context: context, partType: part.type, newID: part.id)
                                } label: {
                                    VStack {
                                        Text(part.name)
                                            .foregroundColor(Color.black)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                    .background(part.getRarityColor(neededRarity: part.rarity))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(part.id == car.bodyId || part.id == car.engineId || part.id == car.wheelId ? Color.white : Color.clear, lineWidth: 4)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .tabViewStyle(.verticalPage)
        } else {
            ProgressView("Loading Data")

        }
    }
}

#Preview {
    Garage()
}
