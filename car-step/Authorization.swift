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
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 200))
                            .padding(.bottom, 60)
                        Text("Steps Counted")
                            .font(.title)
                            .bold()
                        Text("Thank You for allowing us to use your step count")
                            .frame(maxWidth: 300)
                            .multilineTextAlignment(.center)
                        Button("Go to App") {
                            isAllowedReadingSteps = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 20)
                    }
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
                                    allowed = await manager.requestStepAuthorization()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 20)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
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
