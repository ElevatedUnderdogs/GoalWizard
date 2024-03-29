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

    var body: some View {
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
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.trailing)
                }
#endif
                MultiPlatformTextEditor(
                    title: $title,
                    placeholder: "Type your goal",
                    macOSAccessibility: "TitleTextField",
                    iOSAccessibility: "TitleTextEditor"
                )
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
                    Text("Importance/Priority")
                        .foregroundColor(.gray)
                    NumberTextField(
                        placeholder: "(Default is 1 day)",
                        text: $importance,
                        accessibilityIdentifier: "ImportanceTextField",
                        hasDecimals: true
                    )
                }
                MultiPlatformActionButton(
                    title: "Add Goal",
                    accessibilityId: "AddGoalButton"
                ) {
                    parentGoal.addSuBGoal(
                        title: title,
                        estimatedTime: Int64(daysEstimate) ?? 1,
                        importance: importance.removedAllButFirstDecimal
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.top, 20)
                Spacer()
            }
            .padding(.horizontal)
#if os(iOS) || os(tvOS)
            .navigationBarTitle("Add Goal", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.accessibilityIdentifier("CancelButton"))
#endif
        }
    }
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(parentGoal: Goal.start)
    }
}
