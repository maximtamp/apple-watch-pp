//
//  SupabaseService.swift
//  car-step
//
//  Created by Maxim Tampere on 22/01/2026.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    
    //FETCH
    func fetchAll(userId: UUID) async -> (days: [Day], parts: [Part], fuels: [Fuel], cars: [Car], quests: [Quest]) {
        async let days = fetchDays(userId: userId)
        async let parts = fetchParts(userId: userId)
        async let fuels = fetchFuels(userId: userId)
        async let cars = fetchCars(userId: userId)
        async let quests = fetchQuests(userId: userId)
        
        return await (days, parts, fuels, cars, quests)
    }
    
    func fetchDays(userId: UUID) async -> [Day] {
        do {
            let response = try await supabase
                .from("days")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(formatter)

            let dtos = try decoder.decode([DayDTO].self, from: response.data)
            return dtos.map{Day(dto: $0)}
        } catch {
            print("appel")
            return []
        }
    }
    
    func fetchLastSevenDays(userId: UUID) async -> [Day] {
        do {
            let response = try await supabase
                .from("days")
                .select()
                .eq("user_id", value: userId)
                .gte("date", value: Date().addingTimeInterval(-7 * 24 * 60 * 60))
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(formatter)

            let dtos = try decoder.decode([DayDTO].self, from: response.data)
            return dtos.map{Day(dto: $0)}
        } catch {
            print("appel")
            return []
        }
    }
    
    func fetchParts(userId: UUID) async -> [Part] {
        do {
            let response = try await supabase
                .from("parts")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // let op: geen Z
            decoder.dateDecodingStrategy = .formatted(formatter)

            let dtos = try decoder.decode([PartDTO].self, from: response.data)
            return dtos.map { Part(dto: $0) }

        } catch {
            return []
        }
    }
    
    func fetchFuels(userId: UUID) async -> [Fuel] {
        do {
            let response = try await supabase
                .from("fuel")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            let dtos = try JSONDecoder().decode([FuelDTO].self, from: response.data)
            return dtos.map{Fuel(dto: $0)}
        } catch {
            return []
        }
    }
    
    func fetchCars(userId: UUID) async -> [Car] {
        do {
            let response = try await supabase
                .from("cars")
                .select()
                .eq("user_id", value: userId)
                .execute()

            let dtos = try JSONDecoder().decode([CarDTO].self, from: response.data)
            return dtos.map{Car(dto: $0)}
        } catch {
            return []
        }
    }
    
    func fetchQuests(userId: UUID) async -> [Quest] {
        do {
            let response = try await supabase
                .from("quests")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(formatter)

            let dtos = try decoder.decode([QuestDTO].self, from: response.data)
            return dtos.map{Quest(dto: $0)}
        } catch {
            return []
        }
    }
    
    func fetchAllProfiles() async -> [Profile] {
        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .execute()

            let dtos = try JSONDecoder().decode([ProfileDTO].self, from: response.data)
            return dtos.map{Profile(dto: $0)}
        } catch {
            return []
        }
    }
    
    func fetchOthersProfiles(userId: UUID) async -> [Profile] {
        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .neq("id", value: userId)
                .execute()

            let dtos = try JSONDecoder().decode([ProfileDTO].self, from: response.data)
            return dtos.map{Profile(dto: $0)}
        } catch {
            return []
        }
    }
    
    func fetchOFriends(userId: UUID) async -> [Friend] {
        do {
            let response = try await supabase
                .from("friends")
                .select()
                .or("user_id.eq.\(userId),friend_id.eq.\(userId)")
                .execute()

            let dtos = try JSONDecoder().decode([FriendDTO].self, from: response.data)
            return dtos.map{Friend(dto: $0)}
        } catch {
            return []
        }
    }
    
    //INSERT
    func insertDay(_ day: Day) async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            
            let dayToSend = DayInsert(
                id: day.id.uuidString,
                user_id: day.userId.uuidString,
                date: formatter.string(from: day.date),
                total_steps: day.totalSteps,
                claimed_steps: day.claimedSteps,
                used_fuel: day.usedFuel
            )
            
            _ = try await supabase
                .from("days")
                .insert(dayToSend)
                .execute()
        } catch {
            print("Error inserting day:", error)
        }
    }
    
    func insertPart(_ part: Part) async {
        do {
            let partToSend = PartInsert(
                id: part.id.uuidString,
                user_id: part.userId.uuidString,
                name: part.name,
                type: part.type.rawValue,
                rarity: part.rarity.rawValue,
                part_made: part.partMade,
                progress_value: part.progressValue,
                max_value: part.maxValue,
                creation_date: ISO8601DateFormatter().string(from: part.creationDate)
            )
            _ = try await supabase
                .from("parts")
                .insert(partToSend)
                .execute()
        } catch {
            print("Error inserting part:", error)
        }
    }
    
    func insertFuel(_ fuel: Fuel) async {
        do {
            let fuelToSend = FuelInsert(
                user_id: fuel.userId.uuidString,
                value: fuel.value,
            )
            _ = try await supabase
                .from("fuel")
                .insert(fuelToSend)
                .execute()
        } catch {
            print("Error inserting fuel:", error)
        }
    }
    
    func insertCar(_ car: Car) async {
        do {
            let carToSend = CarInsert(
                user_id: car.userId.uuidString,
                body_id: car.bodyId.uuidString,
                engine_id: car.engineId.uuidString,
                wheel_id: car.wheelId.uuidString,
            )
            _ = try await supabase
                .from("cars")
                .insert(carToSend)
                .execute()
        } catch {
            print("Error inserting car:", error)
        }
    }
    
    func insertQuest(_ quest: Quest) async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            
            let questToSend = QuestInsert(
                id: quest.id.uuidString,
                user_id: quest.userId.uuidString,
                date: formatter.string(from: quest.date),
                title: quest.title,
                type: quest.type.rawValue,
                current_value: quest.currentValue,
                needed_value: quest.neededValue,
                claimed: quest.claimed,
                fuel_reward: quest.fuelReward
            )
            
            _ = try await supabase
                .from("quests")
                .insert(questToSend)
                .execute()
        } catch {
            print("Error inserting quest:", error)
        }
    }
    
    func insertFriend(_ friend: Friend) async {
        do {
            let friendToSend = FriendInsert(
                id: friend.id.uuidString,
                user_id: friend.userId.uuidString,
                friend_id: friend.friendId.uuidString,
                is_accepted: friend.isAccepted,
            )
            _ = try await supabase
                .from("friends")
                .insert(friendToSend)
                .execute()
        } catch {
            print("Error inserting friend:", error)
        }
    }
    
    
    //UPDATE
    func updateDay(_ day: Day) async {
        do {
            let dayUpdate = DayUpdate(
                total_steps: day.totalSteps,
                claimed_steps: day.claimedSteps,
                used_fuel: day.usedFuel
            )
            
            _ = try await supabase
                .from("days")
                .update(dayUpdate)
                .eq("id", value: day.id.uuidString)
                .execute()
        } catch {
            print("Error updating day:", error)
        }
    }
    
    func updatePart(_ part: Part) async {
        do {
            let partUpdate = PartUpdate(
                part_made: part.partMade,
                progress_value: part.progressValue,
                creation_date: ISO8601DateFormatter().string(from: part.creationDate)
            )
            
            _ = try await supabase
                .from("parts")
                .update(partUpdate)
                .eq("id", value: part.id.uuidString)
                .execute()
        } catch {
            print("Error updating part:", error)
        }
    }
    
    func updateFuel(_ fuel: Fuel) async {
        do {
            let fuelUpdate = FuelUpdate(
                value: fuel.value
            )
            
            _ = try await supabase
                .from("fuel")
                .update(fuelUpdate)
                .eq("user_id", value: fuel.userId.uuidString)
                .execute()
        } catch {
            print("Error updating fuel:", error)
        }
    }
    
    func updateCar(_ car: Car) async {
        do {
            let carUpdate = CarUpdate(
                body_id: car.bodyId.uuidString,
                engine_id: car.engineId.uuidString,
                wheel_id: car.wheelId.uuidString,
            )
            _ = try await supabase
                .from("cars")
                .update(carUpdate)
                .eq("user_id", value: car.userId.uuidString)
                .execute()
        } catch {
            print("Error inserting car:", error)
        }
    }
    
    func updateQuest(_ quest: Quest) async {
        do {
            let questUpdate = QuestUpdate(
                current_value: quest.currentValue,
                claimed: quest.claimed
            )
            _ = try await supabase
                .from("quests")
                .update(questUpdate)
                .eq("id", value: quest.id.uuidString)
                .execute()
        } catch {
            print("Error inserting quest:", error)
        }
    }
    
    func updateFriend(_ friend: Friend) async {
        do {
            let friendUpdate = FriendUpdate(
                is_accepted: friend.isAccepted
            )

            _ = try await supabase
                .from("friends")
                .update(friendUpdate)
                .eq("id", value: friend.id.uuidString)
                .execute()
        } catch {
            print("Error updating friend:", error)
        }
    }
    
    
    //DELETE
    func deleteFriend(_ friend: Friend) async {
        do {
            _ = try await supabase
                .from("friends")
                .delete()
                .eq("id", value: friend.id.uuidString)
                .execute()
        } catch {
            print("Error deleting friend:", error)
        }
    }
}
