//
//  OneLineTextField.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/14/23.
//

import SwiftUI

struct NumberTextField: View {

    var placeholder: String
    @Binding var text: String
    var accessibilityIdentifier: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.systemGray6 /*Same as the background color. blends.*/))
            .modifier(NumberKeyboardModifier())
            .accessibilityIdentifier(accessibilityIdentifier)
#if os(iOS)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
#endif
    }
}
