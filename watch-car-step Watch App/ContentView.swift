//
//  ContentView.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Home()
            UseFuel()
            Garage()
        }
    }
}

#Preview {
    ContentView()
}
