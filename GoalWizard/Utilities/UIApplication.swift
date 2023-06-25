//
//  UIApplication.swift
//  GoalWizard
//
//  Created by Scott Lydon on 6/25/23.
//

import UIKit

extension UIApplication {

    /// If the app is in dark mode and it doesn't have the dark icon, then set it to the dark icon,
    /// If the app is in the light mode and it doesn't have the primary icon, then set it to primary icon.
    static func matchIconToMode() {
        let current = UIApplication.shared
        guard #available(iOS 12.0, *) else { return }
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .light:
            // If current app icon is not the primary one, switch to the primary one
            if current.alternateIconName != nil {
                current.setAlternateIconName(nil)
            }
        default:
            // If current app icon is not the dark one, switch to the dark one
            if current.alternateIconName != "AppIconBlk" {
                DispatchQueue.main.async {
                    current.setAlternateIconName("AppIconBlk")
                }
            }
        }
    }
}
