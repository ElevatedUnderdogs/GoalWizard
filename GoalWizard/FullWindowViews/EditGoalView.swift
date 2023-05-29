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
                NumberTextField(
                    placeholder: "",
                    text: daysEstimateBinding,
                    accessibilityIdentifier: "DaysEstimateTextField"
                )
                NumberTextField(
                    placeholder: "Importance/Priority (Default is 1 day)",
                    text: importanceBinding,
                    accessibilityIdentifier: "ImportanceTextField",
                    hasDecimals: true
                )
                MultiPlatformActionButton(
                    title: "Close (Saved)",
                    accessibilityId: "Edit Close Button",
                    action: dismiss
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
        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
    // I can initialize a preview and read the body.
    static var previews: some View {
        EditGoalView(goal: Goal.start)
    }
}
