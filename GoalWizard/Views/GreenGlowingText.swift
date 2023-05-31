//
//  GreenGlowingText.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/13/23.
//

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
