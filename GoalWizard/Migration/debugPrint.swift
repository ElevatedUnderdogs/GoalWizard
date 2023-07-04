//
//  debugPrint.swift
//  GoalWizard
//
//  Created by Scott Lydon on 7/4/23.
//

import Foundation

func debugPrint(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    print("Message \"\(message)\" (File: \(file), Function: \(function), Line: \(line))")
    #endif
}
