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

#if os(macOS)
    private let keyPublisher = NotificationCenter.default.publisher(for: NSEvent.keyDownNotification)
#endif

    var body: some View {
        let titleBinder = Binding<String> (
            get: {
                goal.notOptionalTitle
            },
            set: {
                goal.title = $0
                NSPersistentContainer
                    .goalTable
                    .viewContext
                    .updateGoal(
                        goal: goal,
                        title: $0,
                        estimatedTime: goal.daysEstimate
                    )
            }
        )
        let daysEstimateBinding: Binding<String> = Binding<String>(
            get: {
                String(goal.daysEstimate)
            },
            set: {
                if let intValue = Int64($0) {
                    goal.daysEstimate = intValue
                    NSPersistentContainer
                        .goalTable
                        .viewContext
                        .updateGoal(
                            goal: goal,
                            title: goal.title ?? "",
                            estimatedTime: goal.daysEstimate
                        )
                }
            }
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
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.trailing)
                }
#endif
                TextEditor(text: titleBinder)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .lineLimit(nil)

                TextField("", text: daysEstimateBinding)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .modifier(NumberKeyboardModifier())

                Button(action: {
                    presentationMode
                        .wrappedValue.dismiss()
                }) {
                    Text("Close (Saved)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding(.horizontal)
#if os(iOS) || os(tvOS)
            .navigationBarTitle("Edit goal", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
#endif

        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
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
