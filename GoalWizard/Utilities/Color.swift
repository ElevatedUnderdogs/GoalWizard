//
//  Color.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Color {

    static var systemGray6: Color {
        Color("systemGray6")
    }

    static var systemCompatibleTeal: Color {
       #if os(macOS)
       return Color(NSColor.systemTeal)
       #else
       return Color(UIColor.systemTeal)
       #endif
    }

    static var systemCompatibleBlue: Color {
        #if os(macOS)
         return Color(NSColor.systemBlue)
         #else
         return Color(UIColor.systemBlue)
         #endif
    }
}
