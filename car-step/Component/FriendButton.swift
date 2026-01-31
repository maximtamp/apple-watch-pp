//
//  FriendButton.swift
//  car-step
//
//  Created by Maxim Tampere on 28/01/2026.
//

import SwiftUI

struct FriendButton: View {
    var state: String
    var isLoading: Bool
    var insert: () -> Void
    var delete: () -> Void
    var accept: () -> Void
    var deny: () -> Void
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical)
                .background(Color.gray)
            } else if state == "add" || state == "remove" {
                Button {
                    state == "add" ? insert() : delete()
                } label: {
                    Text(state == "remove" ? "Remove Friend" : "Add Friend")
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical)
                        .background(state == "remove" ? Color.red : Color.blue)
                        .foregroundStyle(Color.white)
                }
            } else if state == "request" {
                HStack {
                    Button {
                        deny()
                    } label: {
                        Text("Deny")
                            .bold()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical)
                            .background(Color.red)
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                    }
                    Button {
                        accept()
                    } label: {
                        Text("Accept")
                            .bold()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical)
                            .background(Color.green)
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                    }
                }
            } else {
                Text("Requested")
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                    .background(Color.gray)
                    .foregroundStyle(Color.black.opacity(0.5))
            }
        }
        .cornerRadius(12)
        .frame(height: 24)
    }
}

#Preview {
    FriendButton(state: "add", isLoading: false, insert: {}, delete: {}, accept: {}, deny: {} )
}
