//
//  ReminderField.swift
//  GoalWizard
//
//  Created by Scott Lydon on 7/4/23.
//

import SwiftUI

struct ReminderDatePicker: View {
    @Binding var reminder: Date
    var label: String

    var body: some View {
        VStack(alignment: .leading) {
            DatePicker(
                "",
                selection: $reminder,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
}
