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
    @State private var isLoading: Bool = false
    
    var info = [
        ( icon: "figure.walk", label: "Place steps in real life" ),
        ( icon: "hand.tap.fill", label: "Claim your steps and transfer it to Fuel" ),
        ( icon: "engine.combustion.fill", label: "Use your fuel to make parts" ),
        ( icon: "car.fill", label: "Customise your car with the created parts" ),
        ( icon: "flag.checkered", label: "Race against other users to see who has the fastes car" ),
    ]

    var body: some View {
        TabView {
            VStack {
                Text("Welcome to")
                    .font(.system(size: 32))
                Text("Car Step")
                    .font(.system(size: 64, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 32) {
                ForEach(info, id: \.icon) { item in
                    HStack(spacing: 20) {
                        Image(systemName: item.icon)
                            .font(.system(size: 48))
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color("PrimaryAppColor"))
                            .background(Color("SecondaryAppColor"))
                            .cornerRadius(12)
                        Text(item.label)
                    }
                }
            }
            .padding(40)
            
            VStack {
                Spacer()
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 200))
                    .padding(.bottom, 40)
                Spacer()
                VStack(spacing: 40) {
                    VStack {
                        Text("Give Permission")
                            .font(.system(size: 40, weight: .bold))
                        Text("This app requerds your Step Count to work")
                    }

                    Button {
                        Task {
                            isLoading = true
                            defer { isLoading = false }
                            
                            let allow = await manager.requestStepAuthorization()
                            print(allow)
                            isOnboarding = false
                        }
                    } label: {
                        VStack {
                            if !isLoading {
                                Text("Allow")
                                    .bold()
                            } else {
                                ProgressView()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!isLoading ? Color.blue : Color.gray)
                        .foregroundStyle(Color.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    
                }
                .padding(.top, 20)
                .padding(.bottom, 80)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .tabViewStyle(PageTabViewStyle())
        .foregroundStyle(Color("SecondaryAppColor"))
        .background(Color("PrimaryAppColor"))
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("SecondaryAppColor"))
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color("SecondaryAppColor")).withAlphaComponent(0.4)
        }
    }
}

#Preview {
    Onboarding()
        .environmentObject(HealthKitManager())
}
