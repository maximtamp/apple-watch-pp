//
//  TextButton.swift
//  car-step
//
//  Created by Maxim Tampere on 28/01/2026.
//

import SwiftUI

struct TextButton: View {
    var label: String
    var disabled: Bool
    var action: () -> Void = { }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .bold()
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .padding(.horizontal, 2)
            .background(disabled ? Color.gray : Color.blue)
            .foregroundStyle(Color.white)
            .cornerRadius(12)
        }
        .disabled(disabled)
    }
}

#Preview {
    TextButton(label: "Start", disabled: false)
}
