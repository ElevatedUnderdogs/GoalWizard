//
//  SkeuomorphicButtonStyle.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct SkeuomorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 2, y: 2)
                    .shadow(color: Color.white.opacity(0.7), radius: 2, x: -2, y: -2)
            )
    }
}
