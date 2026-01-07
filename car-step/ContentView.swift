//
//  ContentView.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State var timesClicked: Int = 0
        
    var body: some View {
        VStack {
            Text("Clicked \(timesClicked) times")
            Button("Click") {
                timesClicked += 1
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
