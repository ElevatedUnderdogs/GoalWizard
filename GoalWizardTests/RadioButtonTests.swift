//
//  RadioButtonTests.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/12/23.
//
import XCTest
import SwiftUI
import SnapshotTesting
@testable import GoalWizard
import CommonExtensions

// swiftlint: disable line_length
// class RadioButtonTests: XCTestCase {
//    func testRadioButtonToggling() {
//        var isChecked = false
//        let isCheckedBinding = State<Bool>(
//            get: { isChecked },
//            set: { isChecked = $0 }
//        )
//        let radioButton = RadioButton(isChecked: isChecked)
//
//        let uncheckedSnapshot = takeSnapshot(of: radioButton)
//        let uncheckedColor = uncheckedSnapshot.getPixelColor(at: CGPoint(x: uncheckedSnapshot.size.width / 2, y: uncheckedSnapshot.size.height / 2))
//
//        XCTAssertFalse(radioButton.isChecked, "The initial state should be unchecked.")
//        XCTAssertTrue(isColorClearOrWhite(uncheckedColor), "The center pixel of the unchecked state should be clear or white. was: \(uncheckedColor.hexString) 000000 is black ")
//
//        radioButton.isChecked.toggle()
//
//        let checkedSnapshot = takeSnapshot(of: radioButton)
//        let checkedColor = checkedSnapshot.getPixelColor(at: CGPoint(x: checkedSnapshot.size.width / 2, y: checkedSnapshot.size.height / 2))
//        XCTAssertTrue(radioButton.isChecked, "The state should be checked after toggling.")
//        XCTAssertFalse(isColorClearOrWhite(checkedColor), "The center pixel of the checked state should not be clear or white.")
//    }
//
//
////    private func takeSnapshot(of view: RadioButton) -> UIImage {
////        return Snapshotting.image(on: .white).snapshot(view)
////    }
//
//    private func isColorClearOrWhite(_ color: UIColor) -> Bool {
//        let threshold: CGFloat = 0.9
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        return (red > threshold && green > threshold && blue > threshold) || alpha < threshold
//    }
// }
//
// extension UIImage {
//    func getPixelColor(at point: CGPoint) -> UIColor {
//        let pixelData = self.cgImage!.dataProvider!.data
//        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
//
//        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//        let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
//        let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
//        let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
//
//        return UIColor(red: r, green: g, blue: b, alpha: a)
//    }
// }
//
// extension UIColor {
//    var hexString: String? {
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//            // Using getRed(_:green:blue:alpha:) method
//            return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
//        } else if let components = cgColor.components {
//            if components.count >= 3 {
//                // Using cgColor.components
//                red = components[0]
//                green = components[1]
//                blue = components[2]
//
//                return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
//            }
//        } else if let components = cgColor.components, cgColor.numberOfComponents >= 3 {
//            // Using CGColorGetComponents method
//            red = components[0]
//            green = components[1]
//            blue = components[2]
//
//            return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
//        }
//
//        return nil
//    }
// }
//
// swiftlint: enable line_length
