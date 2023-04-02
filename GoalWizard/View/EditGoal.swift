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

    var body: some View {
        let daysEstimateBinding: Binding<String> = Binding<String>(
            get: {
                String(goal.daysEstimate)
            },
            set: {
                if let intValue = Int($0) {
                    goal.daysEstimate = intValue
                }
            }
        )
        NavigationView {
            VStack {
            #if os(iOS) || os(tvOS)
                EmptyView()
            #else
                HStack {
                    Text("Add Goal")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.trailing)
                }
            #endif
                TextEditor(text: $goal.title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .lineLimit(nil)

                TextField("Days estimate (Default is 1 day)", text: daysEstimateBinding)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .modifier(NumberKeyboardModifier())

                Button(action: {
                    presentationMode
                        .wrappedValue.dismiss()
                }) {
                    Text("Add Goal")
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
            .navigationBarTitle("Add Goal", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        #endif
        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
    static var previews: some View {
        EditGoalView(goal: Goal(title: "Main Goal"))
    }
}
