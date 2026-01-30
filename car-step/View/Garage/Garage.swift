//
//  Garage.swift
//  car-step
//
//  Created by Maxim Tampere on 10/01/2026.
//

import SwiftUI
import SwiftData

struct Garage: View {
    @Environment(AppData.self) private var appData
    
    @Query private var parts: [Part]
    @Query private var cars: [Car]
    
    var tabs = [
        (id: 1, name: "Body", icon: "car.fill"),
        (id: 2, name: "Engine", icon: "engine.combustion.fill"),
        (id: 3, name: "Wheel", icon: "tire"),
    ]
    
    var rarityOrder = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
    
    @State private var selectedTab = "Body"
    
    var body: some View {
        VStack {
            if let car = appData.car {
                VStack {
                    VStack{
                        if let bodyPart = parts.first(where: {$0.id == car.bodyId}), let wheelPart = parts.first(where: {$0.id == car.wheelId}) {
                            CarBuild(wheelName: wheelPart.name, bodyName: bodyPart.name)
                        } else {
                            Text("Make sure to select a body, engine and wheel")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding(.horizontal, 40)
                    .background(Color("BackgroundAppColor"))
                    
                    VStack(spacing: 0) {
                        Picker("Select a tab", selection: $selectedTab) {
                            ForEach(tabs, id: \.id) { tab in
                                Image(systemName: tab.icon)
                                    .font(.title2)
                                    .tag(tab.name)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]){
                                ForEach(
                                    parts
                                        .filter {$0.type.displayName == selectedTab && $0.partMade}
                                        .sorted{partA, partB in
                                            if partA.id == car.bodyId || partA.id == car.engineId || partA.id == car.wheelId {
                                                return true
                                            }
                                            if partB.id == car.bodyId || partB.id == car.engineId || partB.id == car.wheelId {
                                                return false
                                            }
                                            
                                            let rarityA = rarityOrder.firstIndex(of: partA.rarity.displayName) ?? 0
                                            let rarityB = rarityOrder.firstIndex(of: partB.rarity.displayName) ?? 0
                                            return rarityA > rarityB
                                        }
                                ) { part in
                                    
                                    Button {
                                        appData.updateCarPartId(car: car, partType: part.type, newID: part.id)
                                    } label: {
                                        VStack {
                                            Image("\(part.name.lowercased().replacingOccurrences(of: " ", with: "-"))-icon")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(8)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(part.getRarityColor(neededRarity: part.rarity))
                                        .aspectRatio(1, contentMode: .fill)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(part.id == car.bodyId || part.id == car.engineId || part.id == car.wheelId ? Color("SecondaryAppColor") : Color.clear, lineWidth: 4)
                                        )
                                    }
                                }
                            }
                            .padding(12)
                        }
                    }
                    .background(Color("PrimaryAppColor"))
                }
            } else {
                ProgressView("Loading Today's Steps")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
    


#Preview {
    Garage()
}
