//
//  OSNavigationStack.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/9/23.
//

import SwiftUI

struct VersionBasedNavigationStack<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationStack {
                    content
                }
            } else {
                // Difficult path to unit test, not sure how to force a different operating system. 
                NavigationView {
                    content
                }
            }
        }
    }
}
