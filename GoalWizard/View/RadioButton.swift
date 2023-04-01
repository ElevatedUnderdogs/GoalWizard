//
//  RadioButton.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct RadioButton: View {
    @State var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "largecircle.fill.circle" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}
