//
//  SkeuomorphicButtonStyle.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct SkeuomorphicButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.7 : 0.2), radius: 2, x: 2, y: 2)
                    .shadow(color: Color.white.opacity(colorScheme == .dark ? 0.1 : 0.7), radius: 2, x: -2, y: -2)
            )
    }
}
