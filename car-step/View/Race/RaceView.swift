//
//  RaceView.swift
//  car-step
//
//  Created by Maxim Tampere on 25/01/2026.
//

import SwiftUI
import SwiftData

enum RaceState: String, Codable, CaseIterable {
    case selectOpponent
    case versusScreen
    case race
    case endScreen
}

struct RaceView: View {
    var onClose: () -> Void
    
    @Environment(AppData.self) private var appData
    @Query private var parts: [Part]
    
    @State private var profiles: [Profile] = []
    @State private var friendsData: [Friend] = []
    @State private var friends: [Profile] = []
    @State private var todaysRaces: [Race] = []
    
    @State private var opponent: Profile = Profile(id: UUID(), username: "", avatarURL: "")
    @State private var opponentBodyName: String = ""
    @State private var opponentEngineName: String = ""
    @State private var opponentWheelName: String = ""
    @State private var opponentSpeed: Int = 0
    @State private var opponentDuration: Double = 0.0
    @State private var noValidOpponentsLeft: Bool = false
    @State private var noValidOpponents: [Profile] = []
    
    @State private var username: String = ""
    @State private var userBodyName: String = ""
    @State private var userEngineName: String = ""
    @State private var userWheelName: String = ""
    @State private var fuelReward: Int = 0
    @State private var userSpeed: Int = 0
    @State private var userDuration: Double = 0.0
    
    @State private var raceState: RaceState = .selectOpponent
    @State private var isLoading: Bool = false
    @State private var isLoadingPage: Bool = false
    @State private var hasWon: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var runVsAnimation: Bool = false
    @State private var runRaceFadeInAnimation: Bool = false
    @State private var counDownNumber: Int = 3
    
    @State private var runEndAnimation: Bool = false
    
    func startVsAnimation() {
        runVsAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         runVsAnimation = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                raceState = .race
            }
        }
    }
    
    func startRaceAnimation() {
        runRaceFadeInAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            counDownNumber = 2

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                counDownNumber = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    counDownNumber = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + (userDuration < opponentDuration ? userDuration - 1.0 : opponentDuration - 1.0)) {
                        runRaceFadeInAnimation = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            raceState = .endScreen
                        }
                    }
                }
            }
        }
    }
    
    func race(_ opponent: Profile) async {
        isLoading = true
        defer { isLoading = false }
        
        errorMessage = ""
        
        let opponentCar = await SupabaseService.shared.fetchCarParts(for: opponent.id)
        
        guard
            let opponentBody = opponentCar.body,
            let opponentEngine = opponentCar.engine,
            let opponentWheel = opponentCar.wheel
        else {
            errorMessage = "Opponent has no car. Try again."
            noValidOpponents.append(opponent)
            return
        }
        
        opponentBodyName = opponentBody.name
        opponentEngineName = opponentEngine.name
        opponentWheelName = opponentWheel.name

        opponentSpeed = opponentBody.speedPoints + opponentEngine.speedPoints + opponentWheel.speedPoints
                
        guard
            let car = appData.car,
            let userBody = parts.first(where: {$0.id == car.bodyId}),
            let userEngine = parts.first(where: {$0.id == car.bodyId}),
            let userWheel = parts.first(where: {$0.id == car.bodyId})
        else {
            errorMessage = "You don't have a car yet. Restart the app."
            return
        }
        
        userBodyName = userBody.name
        userEngineName = userEngine.name
        userWheelName = userWheel.name
        
        userSpeed = userBody.speedPoints + userEngine.speedPoints + userWheel.speedPoints
        
        let user = await SupabaseService.shared.fetchProfile(userId: appData.currentUserId)
        username = user?.username ?? ""
                
        if userSpeed > opponentSpeed {
            hasWon = true
            fuelReward = 500
        } else if userSpeed == opponentSpeed {
            userSpeed += 5
            hasWon = true
            fuelReward = 500
        } else {
            hasWon = false
            fuelReward = 0
        }
        
        let newRace = Race(
            id: UUID(),
            userId: appData.currentUserId,
            opponentId: opponent.id,
            won: hasWon,
            date: Date()
        )
        
        await SupabaseService.shared.insertRace(newRace)
        if let fuel = appData.fuel {
            appData.updateFuel(fuel: fuel, newValue: fuel.value + fuelReward)
        }
        
        userDuration = duration(userSpeed)
        opponentDuration = duration(opponentSpeed)
        
        raceState = .versusScreen
    }
    
    func duration(_ speed: Int) -> Double {
        let clampedSpeed = min(max(speed, 22), 71)
        let percent = Double(clampedSpeed - 22) / Double(71 - 22)
        return 12.0 - (12.0 - 6.0) * percent
    }
    
    var body: some View {
        VStack {
            if !isLoadingPage {
                switch raceState {
                case .selectOpponent:
                    VStack {
                        Text("Select your opponent")
                            .font(.title)
                            .padding(.top, 160)
                        Button {
                            Task{
                                let availableOpponents = profiles.filter { profile in
                                    guard let username = profile.username, !username.isEmpty else {
                                        return false
                                    }
                                    
                                    if todaysRaces.contains(where: { $0.opponentId == profile.id }) {
                                        return false
                                    }

                                    if noValidOpponents.contains(where: { $0.id == profile.id }) {
                                        return false
                                    }

                                    return true
                                }

                                if let opponentProfile = availableOpponents.randomElement() {
                                    opponent = opponentProfile
                                    await race(opponent)
                                } else {
                                    noValidOpponentsLeft = true
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                } else {
                                    Text(noValidOpponentsLeft ? "No valid opponents left" : "Random opponent")
                                }
                                Spacer()
                            }
                            .frame(height: 16)
                            .padding()
                            .background(isLoading || noValidOpponentsLeft ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || noValidOpponentsLeft)
                        
                        Text(errorMessage)
                            .frame(height: 10)
                            .padding(.top, 8)
                            .foregroundStyle(Color.red)
                        
                        HStack {
                            VStack{
                                Divider()
                                    .background(Color("SecondaryAppColor"))
                            }
                            Text("or a friend")
                                .padding(.horizontal, 8)
                            VStack{
                                Divider()
                                    .background(Color("SecondaryAppColor"))
                            }
                        }
                        .padding(.vertical, 12)
                        
                        ScrollView{
                            ForEach(friends, id: \.id) { friend in
                                let alreadyRaced = todaysRaces.contains(where: { $0.opponentId == friend.id })
                                let notValid = noValidOpponents.contains(where: { $0.id == friend.id })
                                HStack {
                                    Text("\(friend.username ?? "")")
                                    Spacer()
                                    if notValid {
                                        Text("Not valid to race")
                                            .foregroundStyle(Color.black.opacity(0.5))
                                    } else if !alreadyRaced {
                                        Button {
                                            Task {
                                                opponent = friend
                                                await race(opponent)
                                            }
                                        } label: {
                                            HStack {
                                                if isLoading {
                                                    ProgressView()
                                                } else {
                                                    Text("Race")
                                                }
                                            }
                                            .frame(width: 40, height: 8)
                                            .padding()
                                            .background(isLoading ? Color.gray.opacity(0.5) : Color.blue)
                                            .foregroundStyle(Color.white)
                                            .cornerRadius(12)
                                        }
                                        .disabled(isLoading)
                                    } else {
                                        Text("Already raced today")
                                            .foregroundStyle(Color("SecondaryAppColor").opacity(0.5))
                                    }
                                }
                                .padding()
                                .background(alreadyRaced || notValid ? Color("SecondaryAppColor").opacity(0.1) : Color("PrimaryAppColor"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                case .versusScreen:
                    VStack {
                        ZStack(alignment: .bottomTrailing){
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(100)
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 160, height: 160)
                                    .cornerRadius(100)
                            }
                            .padding()
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(100)
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(100)
                            }
                        }
                        .offset(
                            x: runVsAnimation ? 0 : 300,
                            y: runVsAnimation ? 0 : -300
                        )
                        .animation(.snappy(duration: 1.0), value: runVsAnimation)
                        
                        Text("VS")
                            .font(.system(size: 64, weight: .bold))
                            .opacity(runVsAnimation ? 1.0 : 0.0)
                            .animation(.snappy(duration: 1.0), value: runVsAnimation)
                        
                        ZStack(alignment: .topLeading){
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(100)
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 160, height: 160)
                                    .cornerRadius(100)
                            }
                            .padding()
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(100)
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(100)
                            }
                        }
                        .offset(
                            x: runVsAnimation ? 0 : -300,
                            y: runVsAnimation ? 0 : 300
                        )
                        .animation(.snappy(duration: 1.0), value: runVsAnimation)
                    }
                    .onAppear {
                        startVsAnimation()
                    }
                case .race:
                    ZStack {
                        VStack {
                            HStack {
                                VStack(alignment: .leading){
                                    HStack(alignment: .top) {
                                        Text(counDownNumber == 0 ? (hasWon ? "1st" : "2e") : "?")
                                            .foregroundStyle(Color.black)
                                            .frame(width: 32, height: 32)
                                            .padding(8)
                                            .background(counDownNumber == 0 ? (hasWon ? Color.yellow : Color.gray.opacity(0.7)) : Color.gray)
                                            .cornerRadius(12)
                                        Spacer()
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(100)
                                            Rectangle()
                                                .fill(Color.black.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                                .cornerRadius(100)
                                        }
                                    }
                                    
                                    Text("\(username)")
                                        .padding(.top, 8)

                                }
                                .padding()
                                .background(Color("PrimaryAppColor"))
                                .cornerRadius(12)
                                VStack(alignment: .leading){
                                    HStack(alignment: .top) {
                                        Text(counDownNumber == 0 ? (hasWon ? "2e" : "1st") : "?")
                                            .foregroundStyle(Color.black)
                                            .frame(width: 32, height: 32)
                                            .padding(8)
                                            .background(counDownNumber == 0 ? (hasWon ? Color.gray.opacity(0.7) : Color.yellow) : Color.gray)
                                            .cornerRadius(12)
                                        Spacer()
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.red)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(100)
                                            Rectangle()
                                                .fill(Color.black.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                                .cornerRadius(100)
                                        }
                                    }
                                    
                                    Text(opponent.username ?? "Unknown")
                                        .padding(.top, 8)

                                }
                                .padding()
                                .background(Color("PrimaryAppColor"))
                                .cornerRadius(12)
                            }
                            .padding()
                            .padding(.bottom)

                            ZStack{
                                Image("race-track")
                                
                                if counDownNumber != 0 {
                                    RaceCar(color: .blue, duration: userDuration, run: 0.0)
                                    RaceCar(color: .red, duration: opponentDuration, run: 0.0)
                                } else {
                                    RaceCar(color: .blue, duration: userDuration, run: 1.0)
                                    RaceCar(color: .red, duration: opponentDuration, run: 1.0)
                                }
                            }
                        }
                        if counDownNumber > 0 {
                            ZStack {
                                Text("\(counDownNumber)")
                                    .font(.system(size: 80, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.4))
                        }
                    }
                    .opacity(runRaceFadeInAnimation ? 1.0 : 0.0)
                    .animation(.snappy(duration: 0.5), value: runRaceFadeInAnimation)
                    .onAppear {
                        startRaceAnimation()
                    }
                case .endScreen:
                    VStack {
                        VStack{
                            Spacer()
                            VStack(spacing: 4){
                                Text(hasWon ? "You Won!" : "You Lose!")
                                    .font(.system(size: 64, weight: .bold))
                                if hasWon {
                                    HStack {
                                        ZStack {
                                            Image(systemName: "bolt.fill")
                                                .font(.system(size: 24))
                                        }
                                        .frame(width: 40, height: 40)
                                        .background(Color.red.opacity(0.5))
                                        .cornerRadius(90)
                                        Text("500")
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                            Spacer()
                        }
                        .offset(
                            x: 0,
                            y: runEndAnimation ? 0 : -200
                        )
                        .animation(.snappy(duration: 1.0), value: runEndAnimation)
                        Spacer()
                        HStack(alignment: .bottom, spacing: 12) {
                            VStack{
                                ZStack {
                                    Rectangle()
                                        .fill(hasWon ? Color.blue : Color.red)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(100)
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(100)
                                }
                                ZStack {
                                    Rectangle()
                                        .fill(Color.yellow)
                                        .frame(width: 120, height: 200)
                                        .cornerRadius(10)
                                    Text("1")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 64, weight: .bold))
                                }
                            }
                            .offset(
                                x: runEndAnimation ? 0 : -200,
                                y: 0
                            )
                            .animation(.snappy(duration: 1.0), value: runEndAnimation)
                            VStack{
                                ZStack {
                                    Rectangle()
                                        .fill(hasWon ? Color.red : Color.blue)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(100)
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(100)
                                }
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.7))
                                        .frame(width: 120, height: 140)
                                        .cornerRadius(10)
                                    Text("2")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 64, weight: .bold))
                                }
                            }
                            .offset(
                                x: runEndAnimation ? 0 : 200,
                                y: 0
                            )
                            .animation(.snappy(duration: 1.0), value: runEndAnimation)
                        }
                        .padding(.bottom, 40)
                        Button {
                            onClose()
                        } label: {
                            HStack {
                                Spacer()
                                Text(hasWon ? "Claim" : "Close")
                                    .bold()
                                Spacer()
                            }
                            .frame(height: 16)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                        }
                        .offset(
                            x: 0,
                            y: runEndAnimation ? 0 : 100
                        )
                        .animation(.snappy(duration: 1.0), value: runEndAnimation)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                    .onAppear {
                        runEndAnimation = true
                    }
                }
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.05))
        .onAppear {
            Task {
                isLoadingPage = true
                defer { isLoadingPage = false }
                
                profiles = await SupabaseService.shared.fetchOthersProfiles(userId: appData.currentUserId)
                friendsData = await SupabaseService.shared.fetchOFriends(userId: appData.currentUserId)
                
                friends = friendsData
                    .filter { $0.isAccepted }
                    .compactMap { relation in
                        let otherId = relation.userId == appData.currentUserId ? relation.friendId : relation.userId
                        return profiles.first { $0.id == otherId }
                    }
                
                todaysRaces = await SupabaseService.shared.fetchTodaysRaces(userId: appData.currentUserId)
            }
        }
    }
}
