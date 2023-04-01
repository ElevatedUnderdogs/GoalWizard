//
//  NumberKeyboardModifier.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

// Add this struct for conditional keyboardType modifier
struct NumberKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS)
        content.keyboardType(.numberPad)
        #else
        content
        #endif
    }
}
