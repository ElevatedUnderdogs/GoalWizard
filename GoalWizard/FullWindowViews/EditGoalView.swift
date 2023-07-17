//
//  EditGoal.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/2/23.
//

import SwiftUI

struct EditGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var goal: Goal

    @State var reminderDate: Date?
    @State var reminderDate2: Date?

    @State var showReminder1Picker = false
    @State var showReminder2Picker = false

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func setGoal(title: String) {
        goal.title = title
        Goal.context.updateGoal(
            goal: goal,
            title: title,
            estimatedTime: goal.daysEstimate,
            importance: goal.importance
        )
    }

    func set(dayEstimate: String) {
        guard let intValue = Int64(dayEstimate) else { return }
        goal.daysEstimate = intValue
        Goal.context.updateGoal(
            goal: goal,
            title: goal.notOptionalTitle,
            estimatedTime: goal.daysEstimate,
            importance: goal.importance
        )
    }

    func set(importance: String) {
        guard importance.removedAllButFirstDecimal.decimal != nil else { return }
        goal.importance = importance
        Goal.context.updateGoal(
            goal: goal,
            title: goal.notOptionalTitle,
            estimatedTime: goal.daysEstimate,
            importance: goal.importance
        )
    }

    var body: some View {
        let titleBinder = Binding<String>(
            get: { goal.notOptionalTitle },
            set: { setGoal(title: $0) }
        )
        let daysEstimateBinding: Binding<String> = Binding<String>(
            get: { String(goal.daysEstimate) },
            set: { set(dayEstimate: $0) }
        )
        let importanceBinding: Binding<String> = Binding<String>(
            get: { goal.importance.string },
            set: { set(importance: $0) }
        )
        NavigationView {
            ScrollView {
                VStack {
#if os(iOS) || os(tvOS)
                    EmptyView()
#else
                    HStack {
                        Text("Edit Goal")
                            .font(.headline)
                            .padding(.leading)
                        Spacer()
                        Button("Done") {
                            dismiss()
                        }
                        .padding(.trailing)
                    }
#endif
                    MultiPlatformTextEditor(
                        title: titleBinder,
                        placeholder: "Edit goal",
                        macOSAccessibility: "EditGoalTextField",
                        iOSAccessibility: "EditGoalTextField"
                    )
                    .frame(minHeight: 200)
                    HStack {
                        Text("Days Estimate")
                            .foregroundColor(.gray)
                        NumberTextField(
                            placeholder: "",
                            text: daysEstimateBinding,
                            accessibilityIdentifier: "DaysEstimateTextField"
                        )
                    }
                    HStack {
                        Text("Importance/Priority")
                            .foregroundColor(.gray)
                        NumberTextField(
                            placeholder: "Importance/Priority (Default is 1 day)",
                            text: importanceBinding,
                            accessibilityIdentifier: "ImportanceTextField",
                            hasDecimals: true
                        )
                    }
                    ContentRevealerToggle(toggleText: reminderDate.reminderText(for: "1")) {
                        ReminderDatePicker(
                            reminder: Binding<Date>(
                                get: { self.reminderDate ?? Date() },
                                set: { self.reminderDate = $0 }
                            ),
                            label: "Add Reminder 1"
                        )
                    }

                    ContentRevealerToggle(toggleText: reminderDate2.reminderText(for: "2")) {
                        ReminderDatePicker(
                            reminder: Binding<Date>(
                                get: { self.reminderDate2 ?? Date() },
                                set: { self.reminderDate2 = $0 }
                            ),
                            label: "Reminder 2"
                        )
                    }
                    MultiPlatformActionButton(
                        title: "Save",
                        accessibilityId: "Edit Close Button",
                        action: {
                            let notificationCenter = UNUserNotificationCenter.current()
                            notificationCenter.requestAuthorization(options: [.alert, .sound]) { accepted, _ in
                                guard accepted else { return }
                                if let goalId = goal.id {
                                    let id1 = "\(goalId.uuidString)-reminder1"
                                    let id2 = "\(goalId.uuidString)-reminder2"
                                    // Remove existing notifications
                                    notificationCenter.removeNotification(id: id1)
                                    notificationCenter.removeNotification(id: id2)

                                    // Update new notifications if reminders are set
                                    if let reminderDate {
                                        notificationCenter.scheduleNotification(
                                            id: id1,
                                            title: "Reminder",
                                            body: "Don't forget to work on your goal: \(goal.title ?? "")",
                                            date: reminderDate
                                        )
                                    }

                                    if let reminderDate2 {
                                        notificationCenter.scheduleNotification(
                                            id: id2,
                                            title: "Reminder",
                                            body: "Don't forget to work on your goal: \(goal.title ?? "")",
                                            date: reminderDate2
                                        )
                                    }
                                }
                            }
                            dismiss()
                        }
                    )
                    .padding(.top, 20)
                    Spacer()
                }
                .padding(.horizontal)
#if os(iOS) || os(tvOS)
                .navigationBarTitle("Edit goal", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    // I can make an editView ui test and tap the done button.
                    dismiss()
                }.accessibilityIdentifier("DoneButton"))
#endif
                .onAppear {
                    guard let goalId = goal.id else { return }
                    let reminder1Id = "\(goalId.uuidString)-reminder1"
                    let reminder2Id = "\(goalId.uuidString)-reminder2"

                    UNUserNotificationCenter
                        .current()
                        .fetchReminders(
                            with: [reminder1Id, reminder2Id]
                        ) { reminderDates in
                            debugPrint(reminderDates[reminder1Id] as Any, reminderDates[reminder2Id] as Any)
                            self.reminderDate = reminderDates[reminder1Id]
                            self.reminderDate2 = reminderDates[reminder2Id]
                        }
                }
            }
        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
    // I can initialize a preview and read the body.
    static var previews: some View {
        EditGoalView(goal: .start)
    }
}
