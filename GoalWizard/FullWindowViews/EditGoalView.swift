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
            estimatedTime: goal.daysEstimate
        )
    }

    func set(dayEstimate: String) {
        // I can target this with a unit test passing a word "hello world".
        guard let intValue = Int64(dayEstimate) else { return }
        goal.daysEstimate = intValue
        Goal.context.updateGoal(
            goal: goal,
            // I can target this with a unit test setting the goal title to nil
            title: goal.title ?? "",
            estimatedTime: goal.daysEstimate
        )
    }

    var body: some View {
        let titleBinder = Binding<String> (
            get: { goal.notOptionalTitle },
            set: { setGoal(title: $0) }
        )
        let daysEstimateBinding: Binding<String> = Binding<String>(
            get: { String(goal.daysEstimate) },
            // I can target this with an EditView ui test where I change the days estimate.
            set: { set(dayEstimate: $0) }
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
                TextField("Edit goal", text: titleBinder)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .lineLimit(0)
                    .accessibilityIdentifier("EditGoalTextField")
                TextField("", text: daysEstimateBinding)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .modifier(NumberKeyboardModifier())
                    .accessibilityIdentifier("DaysEstimateTextField")
                Button(action: {
                    dismiss()
                }) {
#if os(iOS)
                    Text("Close (Saved)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                        .accessibilityIdentifier("AddGoalButton")
#else
                    Text("Close (Saved)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                    // .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                        .accessibilityIdentifier("AddGoalButton")
#endif
                }
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
        EditGoalView(goal: Goal.edit)
    }
}

import CoreData

fileprivate extension Goal {

    static var edit: Goal {
        let goal = Goal(context: Goal.context)
        goal.estimatedCompletionDate = ""
        goal.id = UUID()
        goal.title = "Edit me!"
        goal.daysEstimate = 1
        goal.thisCompleted = false
        goal.progress = 0
        goal.progressPercentage = ""
        goal.steps = []
        goal.topGoal = true
        goal.updateProgressUpTheTree()
        goal.updateCompletionDateUpTheTree()
        return goal
    }
}
