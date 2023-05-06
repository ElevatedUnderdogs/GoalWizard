//
//  TestableHelpers.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/10/23.
//

import Foundation

protocol HasCallCodable {
    func callCodable<T: Codable>(
        expressive: Bool,
        _ action: @escaping (T?)->Void
    )
}

extension URLRequest: HasCallCodable {}

protocol HasAsync {
    func async(execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: HasAsync {}

typealias Action = () -> Void
typealias ErrorAction = (Error?) -> Void
