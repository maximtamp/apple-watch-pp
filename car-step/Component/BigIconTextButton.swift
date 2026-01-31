//
//  BigIconTextButton.swift
//  car-step
//
//  Created by Maxim Tampere on 28/01/2026.
//

import SwiftUI

struct BigIconTextButton: View {
    var label: String
    var icon: String
    var disabled: Bool?
    var action: () -> Void = { }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.system(size: 14))
                    .bold()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical)
            .padding(.horizontal, 2)
            .background(disabled ?? false ? Color.gray : Color.blue)
            .foregroundStyle(Color.white)
            .cornerRadius(12)
        }
        .disabled(disabled ?? false)
    }
}

#Preview {
    BigIconTextButton(label: "home", icon: "house", disabled: true)
}
