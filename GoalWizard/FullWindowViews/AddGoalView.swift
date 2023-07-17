//
//  AddGoalView.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI
import CoreData

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var parentGoal: Goal

    // Simply read these two properties in a unit test.
    @State var title: String = ""
    @State var daysEstimate: String = ""
    @State var importance: String = ""
    @State var reminder1: Date = Date()
    @State var reminder2: Date = Date().addingTimeInterval(60 * 60 * 24) // 1 day later
    @State var showReminder1Picker = false
    @State var showReminder2Picker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
#if os(iOS) || os(tvOS)
                    EmptyView()
#else
                    HStack {
                        Text("Add Sub Goal to \(parentGoal.notOptionalTitleClipped)")
                            .font(.headline)
                            .padding(.leading)
                        Spacer()
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.trailing)
                    }
#endif
                    MultiPlatformTextEditor(
                        title: $title,
                        placeholder: "Type your sub-goal to \"\(parentGoal.notOptionalTitleClipped)\"",
                        macOSAccessibility: "TitleTextField",
                        iOSAccessibility: "TitleTextEditor"
                    )
                    .frame(minHeight: 200)
                    HStack {
                        Text("Days Estimate")
                            .foregroundColor(.gray)
                        NumberTextField(
                            placeholder: "(Default is 1 day)",
                            text: $daysEstimate,
                            accessibilityIdentifier: "DaysEstimateTextField"
                        )
                    }
                    HStack {
                        Text(parentGoal.importanceText)
                            .foregroundColor(.gray)
                        NumberTextField(
                            placeholder: "(Default is 1 day)",
                            text: $importance,
                            accessibilityIdentifier: "ImportanceTextField",
                            hasDecimals: true
                        )
                    }
                    ContentRevealerToggle(toggleText: "Set Reminder 1") {
                        ReminderDatePicker(reminder: $reminder1, label: "Reminder 1")
                    }
                    ContentRevealerToggle(toggleText: "Set Reminder 2") {
                        ReminderDatePicker(reminder: $reminder1, label: "Reminder 2")
                    }
                    MultiPlatformActionButton(
                        title: "Add Goal",
                        accessibilityId: "AddGoalButton"
                    ) {
                        if let newSubGoalUUID: UUID = parentGoal.addSuBGoal(
                            title: title,
                            estimatedTime: Int64(daysEstimate) ?? 1,
                            importance: importance.removedAllButFirstDecimal
                        ) {
                            let id1 = "\(newSubGoalUUID.uuidString)-reminder1"
                            let id2 = "\(newSubGoalUUID.uuidString)-reminder2"

                            UNUserNotificationCenter.current().updateNotification(
                                id: id1,
                                title: "Reminder 1",
                                body: "It's time for your goal: \(title)",
                                date: reminder1
                            )
                            UNUserNotificationCenter.current().updateNotification(
                                id: id2,
                                title: "Reminder 2",
                                body: "It's time for your goal: \(title)",
                                date: reminder2
                            )
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.top, 20)
                    Spacer()
                }
                .padding(.horizontal)
#if os(iOS) || os(tvOS)
                .navigationBarTitle("Add Sub Goal", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }.accessibilityIdentifier("CancelButton"))
#endif
            }
        }
    }
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(parentGoal: Goal.start)
    }
}
