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
        if let allowed = authorizationStatus {
            if allowed {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 200))
                        .padding(.bottom, 60)
                    Text("Steps Counted")
                        .font(.title)
                        .bold()
                    Text("Thank You for allowing us to use your step count")
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                    Button("Explore") {
                        isOnboarding = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.9))
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 200))
                        .padding(.bottom, 60)
                    Text("You did not give us access!")
                        .font(.title)
                        .bold()
                    Text("You can still do this in settings. Go to Setting > Privacy and Security > Health > Car Step")
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    HStack {
                        Button("Go to Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.bordered)
                        Button("Refresh") {
                            Task {
                                let allowed = await manager.requestStepAuthorization()
                                authorizationStatus = allowed
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 20)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.9))
            }
        } else {
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
                            let allowed = await manager.requestStepAuthorization()
                            authorizationStatus = allowed
                            if allowed {
                                print("Allowed ✅")
                            } else {
                                print("Not Allowed ❌")
                            }
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
}

#Preview {
    Onboarding()
        .environmentObject(HealthKitManager(preview: true))
}
