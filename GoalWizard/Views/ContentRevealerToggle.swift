//
//  ContentRevealerToggle.swift
//  GoalWizard
//
//  Created by Scott Lydon on 7/13/23.
//

import SwiftUI

typealias BoolAction = (Bool) -> Void

struct ContentRevealerToggle<Content: View>: View {
    @State var showContent: Bool = false
    let toggleText: String
    let content: () -> Content
    let onToggle: BoolAction?

    init(
        toggleText: String,
        @ViewBuilder content: @escaping () -> Content,
        onToggle: BoolAction? = nil
    ) {
        self.toggleText = toggleText
        self.content = content
        self.onToggle = onToggle
    }

    var body: some View {
        Toggle(isOn: $showContent) {
            Text(toggleText)
        }
        .onChange(of: showContent) { newValue in
            if newValue {
                UIApplication.shared.endEditing()
            }
            onToggle?(newValue)
        }

        if showContent {
            content()
        }
    }
}
