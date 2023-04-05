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

    @State private var title: String = ""
    @State private var daysEstimate: String = ""

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
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.trailing)
                }
            #endif
                TextEditor(text: $title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .lineLimit(nil)

                TextField("Days estimate (Default is 1 day)", text: $daysEstimate)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .modifier(NumberKeyboardModifier())

                Button(action: {
                    NSPersistentContainer.goalTable.viewContext.createAndSaveGoal(
                        title: title,
                        estimatedTime: Int64(daysEstimate) ?? 1,
                        parent: parentGoal
                    )
                    presentationMode.wrappedValue.dismiss()
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

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(parentGoal: Goal.start)
    }
}
