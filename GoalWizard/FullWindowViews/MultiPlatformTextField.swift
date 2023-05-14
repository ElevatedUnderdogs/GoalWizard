//
//  MultiPlatformTextField.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/14/23.
//

import SwiftUI

struct MultiPlatformTextEditor: View {
    @Binding var title: String
    var placeholder: String
    @State var macOSAccessibility: String = "TitleTextField"
    @State var iOSAccessibility: String = "TitleTextEditor"

    var body: some View {
        #if os(macOS)
            TextField(placeholder, text: $title)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                // This isn't word wrapping still
                .lineLimit(0)
                .accessibilityIdentifier(macOSAccessibility)
        #else
            VStack(alignment: .leading) {
                Text("\(placeholder):")
                    .foregroundColor(Color.gray)
                TextEditor(text: $title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    // This isn't word wrapping still
                    .lineLimit(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .accessibilityIdentifier(iOSAccessibility)
            }
        #endif
    }
}
