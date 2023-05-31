//
//  MultiPlatformActionButton.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/14/23.
//

import SwiftUI

struct MultiPlatformActionButton: View {
    var title: String
    var accessibilityId: String
    var action: Action

    var body: some View {
        Button(action: action) {
       #if os(iOS)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                .accessibilityIdentifier(accessibilityId)
       #else
            Text("Add Goal")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
            // .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                .accessibilityIdentifier(accessibilityId)
       #endif
        }
    }
}
