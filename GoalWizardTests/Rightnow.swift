//
//  Rightnow.swift
//  GoalWizardTests
//
//  Created by Scott Lydon on 4/10/23.
//

import XCTest
@testable import GoalWizard
import CoreData

struct RightNow: HasAsync {
    func async(execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
