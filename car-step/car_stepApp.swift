//
//  car_stepApp.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData
import HealthKit
import Supabase

@main
struct car_stepApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    
    let container: ModelContainer = {
        try! ModelContainer(for: Day.self, Part.self, Fuel.self, Car.self, Quest.self)
    }()

    @State private var appData = AppData(currentUserId: UUID())
    @StateObject private var manager = HealthKitManager()
    
    @State var isAuthenticated = false
    @State var needsUsername = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    if needsUsername {
                        EditProfile(
                            onSave: {
                                needsUsername = false
                            },
                            pageTitle: "Create Profile",
                            buttonLabel: "Create",
                            username: ""
                        )
                    } else {
                        if isOnboarding {
                            Onboarding()
                                .environmentObject(manager)
                        } else {
                            ContentView()
                                .environmentObject(manager)
                                .environment(appData)
                                .environment(\.modelContext, container.mainContext)
                                .onAppear {
                                    WatchConnectivitySync.shared.setup(
                                        context: container.mainContext,
                                        appData: appData
                                    )
                                }
                        }
                    }
                } else {
                    AuthView()
                }
            }
            .task {
                if !hasLaunchedBefore {
                    hasLaunchedBefore = true
                    try? await supabase.auth.signOut()
                    await appData.resetApp(context: container.mainContext)
                }
                for await state in supabase.auth.authStateChanges {
                    switch state.event {
                    case .initialSession:
                        if let session = state.session {
                            isAuthenticated = true
                            appData.currentUserId = session.user.id
                            appData.didJustLogin = false
                            await checkUsername(session: session)
                        }
                    case .signedIn:
                        isAuthenticated = true
                        appData.currentUserId = state.session!.user.id
                        appData.didJustLogin = true
                        await checkUsername(session: state.session!)
                    case .signedOut:
                        isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func checkUsername(session: Session) async {
        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: session.user.id)
                .execute()
            
            let data = response.data
            
            let profiles = try JSONDecoder().decode([ProfileDTO].self, from: data)
            
            if let profile = profiles.first {
                let missing = profile.username == nil || profile.username!.isEmpty
                needsUsername = missing
            } else {
                needsUsername = true
            }
        } catch {
            needsUsername = false
        }
    }
}
