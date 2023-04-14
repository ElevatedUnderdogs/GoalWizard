//
//  RadioPreviewTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/13/23.
//

import XCTest
@testable import GoalWizard
import CoreData

class RadioPreviewTests: XCTestCase {

    func testRadio() {
        RadioButton_Previews.isChecked = true
        let _ = RadioButton_Previews.previews
        let radio = RadioButton(isChecked: .constant(false))
        radio.isChecked = true
        let _ = radio.body
        radio.isChecked = false
        let greenGlow = GreenGlowingText(text: "Completed")
        let _ = greenGlow.body
    }
}
