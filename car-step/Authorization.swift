//
//  Authorization.swift
//  car-step
//
//  Created by Maxim Tampere on 19/01/2026.
//

import SwiftUI

struct Authorization: View {
    
    @AppStorage("isAllowedReadingSteps") var isAllowedReadingSteps: Bool?
    @EnvironmentObject var manager: HealthKitManager

    @State private var allowed = false
    @State var isLoading = true

    
    var body: some View {
        VStack{
            if !isLoading {
                if allowed {
                    VStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 200))
                            .padding(.bottom, 60)
                        Spacer()
                        VStack(spacing: 40) {
                            VStack {
                                Text("Steps Counted")
                                    .font(.title)
                                    .bold()
                                Text("Thank You for allowing us to use your step count")
                                    .frame(maxWidth: 300)
                                    .multilineTextAlignment(.center)
                            }
                            TextButton(label: "Go to App", disabled: false){
                                isAllowedReadingSteps = true
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 200))
                            .padding(.bottom, 60)
                        Spacer()
                        VStack(spacing: 40) {
                            VStack {
                                Text("You did not give us access!")
                                    .font(.title)
                                    .bold()
                                Text("You can still do this in settings. Go to Setting > Privacy and Security > Health > Car Step")
                                    .frame(maxWidth: 300)
                                    .multilineTextAlignment(.center)
                            }
                            VStack(spacing: 20) {
                                TextButton(label: "Refresh", disabled: false){
                                    Task {
                                        allowed = await manager.requestStepAuthorization()
                                    }
                                }
                                
                                Button("Go to Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(Color("SecondaryAppColor"))
                            }
                            .padding(.top, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(Color("SecondaryAppColor"))
        .background(Color("PrimaryAppColor"))
        .onAppear {
            Task {
                isLoading = true
                allowed = await manager.requestStepAuthorization()
                isLoading = false
            }
        }
    }
}

#Preview {
    Authorization()
}
