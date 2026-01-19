//
//  Onboarding.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import SwiftUI

struct Onboarding: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @EnvironmentObject var manager: HealthKitManager
    
    @State private var authorizationStatus: Bool? = nil

    var body: some View {
        TabView {
            VStack {
                Text("Welcome to")
                    .font(.system(size: 32))
                Text("Car Step")
                    .font(.system(size: 64, weight: .bold))
            }
            VStack {
                Text("Bla, Bla, Bla, ...")
            }
            VStack {
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 200))
                    .padding(.bottom, 40)
                Text("Give Permission")
                    .font(.system(size: 40, weight: .bold))
                Text("This app requerds your Step Count to work")
                Button("Allow") {
                    Task {
                        let allow = await manager.requestStepAuthorization()
                        print(allow)
                        isOnboarding = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .foregroundStyle(.white)
        .background(Color.black.opacity(0.9))
            
    }
}

#Preview {
    Onboarding()
        .environmentObject(HealthKitManager())
}
