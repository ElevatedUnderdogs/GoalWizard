//
//  XCUIElement.swift
//  GoalWizardUITests
//
//  Created by Scott Lydon on 5/13/23.
//

import XCTest

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.isHittable {
            let startPoint = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
            let endPoint = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            startPoint.press(forDuration: 0.01, thenDragTo: endPoint)
        }
    }
}
