//
//  Garage.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI

struct Garage: View {
    
    let parts: [(name: String, icon: String, data: [String])] = [
        (name: "Bodies", icon: "car.fill", data: ["Shell Rover", "Wing Chassis", "Crest Shell", "Phoenix Carapace", "Aura Frame"]),
        (name: "Engines", icon: "engine.combustion.fill", data: ["Engine V1", "Bolt Core", "Gear V8", "Flare Pulse Unit", "Reactor"]),
        (name: "Wheels", icon: "tire", data: ["Ring Hoops", "Spoke Treads", "Bolt Spinners", "Vortex Rollers", "Nebula Glidewheels"]),
    ]
    
    let car = (
        body: "Wing Chassis",
        engine: "Bolt Core",
        wheel: "Ring Hoops",
        color: Color.blue
    )
    
    var body: some View {
        
        TabView {
            VStack {
                Text("Body: \(car.body)")
                Text("Engine: \(car.engine)")
                Text("Wheel: \(car.wheel)")
            }
            .background(car.color)
            
            ForEach(parts, id: \.name) { part in
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: part.icon)
                        Text(part.name)
                    }
                    List(part.data, id: \.self) { name in
                        Text(name)
                    }
                }
            }
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    Garage()
}
