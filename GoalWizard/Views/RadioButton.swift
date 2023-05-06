//
//  RadioButton.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct RadioButton: View {
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
            // Tap the check box 3 times.
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "largecircle.fill.circle" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}


struct RadioButton_Previews: PreviewProvider {
    @State static var isChecked = false
    @State static var isUnchecked = true

    static var previews: some View {
        Group {
            RadioButton(isChecked: $isUnchecked)
            // No point of testing this.
                .previewDisplayName("Checked")
                .onAppear { isChecked = false }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


import SwiftUI

struct GreenGlowingText: View {
    var text: String

    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(.goalGreen)
                .font(.body)
                .blur(radius: 5)
                .opacity(0.7)

            Text(text)
                .foregroundColor(.goalGreen)
                .font(.body)
        }
    }
}
