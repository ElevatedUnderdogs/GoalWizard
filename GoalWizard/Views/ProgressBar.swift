//
//  ProgressBar.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct ProgressBar: View {
    var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.systemCompatibleTeal)

                Rectangle()
                    .frame(
                        width: min(
                            CGFloat(self.value) *  geometry.size.width,
                            geometry.size.width
                        ),
                        height: geometry.size.height
                    )
                    .foregroundColor(Color.systemCompatibleBlue)
            }.cornerRadius(45.0)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Progress Bar")
                .accessibilityValue("\(Int(value * 100))%")
        }
    }
}
