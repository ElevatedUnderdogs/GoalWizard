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
    @State var hasDecimals: Bool = false

    var body: some View {
        let decimalText = Binding<String>(
            // it has an off off on pattern.
            get: { text },
            set: { text = $0.removedAllButFirstDecimal }
        )
        TextField(placeholder, text: decimalText)
#if os(iOS)
            .keyboardType(hasDecimals ? .decimalPad : .numberPad)
#endif
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.systemGray6 /*Same as the background color. blends.*/))
            .accessibilityIdentifier(accessibilityIdentifier)
            .frame(height: 60)
#if os(iOS)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
#endif

    }
}
