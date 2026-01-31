//
//  Garage.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct Garage: View {
    
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
                    HStack{
                        Image(systemName: "door.garage.closed")
                        Text("Garage")
                        Spacer()
                    }
                    if let bodyPart = parts.first(where: {$0.id == car.bodyId}), let wheelPart = parts.first(where: {$0.id == car.wheelId}) {
                        CarBuild(wheelName: wheelPart.name, bodyName: bodyPart.name)
                    } else {
                        Text("Make sure to select a body, engine and wheel")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ForEach(tabs, id: \.id) { tab in
                    ScrollView{
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: tab.icon)
                                Text(tab.name)
                            }
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]){
                                ForEach(
                                    parts
                                        .filter {$0.type.displayName == tab.name && $0.partMade}
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
                                        .cornerRadius(8)
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
