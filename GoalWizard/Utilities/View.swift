//
//  View.swift
//  GoalWizard
//
//  Created by Scott Lydon on 7/5/23.
//

import SwiftUI

extension View {
    func searchFieldStyle() -> some View {
         padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
            .accessibilityIdentifier("Search TextField")
    }
}
