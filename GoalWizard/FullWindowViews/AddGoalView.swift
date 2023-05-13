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

    // swiftlint: disable multiple_closures_with_trailing_closure
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

            #if os(macOS)
                TextField("Type your goal", text: $title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    // This isn't word wrapping still
                    .lineLimit(0)
                    .accessibilityIdentifier("TitleTextField")
            #else
                VStack(alignment: .leading) {
                    Text("Type your goal:")
                        .foregroundColor(Color.gray)
                    TextEditor(text: $title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                        // This isn't word wrapping still
                        .lineLimit(0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .accessibilityIdentifier("TitleTextEditor")
                }
                #endif
                TextField("Days estimate (Default is 1 day)", text: $daysEstimate)
                    .padding()
                    // Same as the background color. blends.
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                    .modifier(NumberKeyboardModifier())
                    .accessibilityIdentifier("DaysEstimateTextField")
                #if os(iOS)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
#endif
                Button(
                    action: {
                        parentGoal.addSuBGoal(title: title, estimatedTime: Int64(daysEstimate) ?? 1)
                        presentationMode.wrappedValue.dismiss()
                    }
                ) {
#if os(iOS)
                    Text("Add Goal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBlue)))
                        .accessibilityIdentifier("AddGoalButton")
                #else
                    Text("Add Goal")
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
            .navigationBarTitle("Add Goal", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.accessibilityIdentifier("CancelButton"))
        #endif
        }
    }
    // swiftlint: enable multiple_closures_with_trailing_closure
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(parentGoal: Goal.start)
    }
}
