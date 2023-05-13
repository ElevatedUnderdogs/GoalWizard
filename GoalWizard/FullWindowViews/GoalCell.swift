//
//  GoalCell.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/10/23.
//

import SwiftUI

struct GoalCell: View {
    @Binding var step: Goal
    let searchText: String
    let index: Int
    var pasteBoard: GoalPasteBoard

    var body: some View {
        HStack {
            VStack {
                HStack {
                    if searchText.isEmpty {
                        Text("\(index + 1).")
                            .font(.title2)
                    }
                    ProgressBar(value: step.progress)
                        .frame(height: 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                    // Difficult to test, should never reach.
                    Text(step.notOptionalProgressPercentage)
                }
                HStack {
                    Text("\(step.notOptionalTitle)")
                        .font(.title2)
                    Spacer()
                }

                Spacer()
                    .frame(height: 10)
                HStack(alignment: .top) {
                    Text("\(step.subGoalCount) sub-goals")
                        .font(.caption2)
                        .foregroundColor(Color.systemCompatibleTeal)
                    Spacer()
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                    } else {
                        // This is difficult to test because ?? "" should never be reached. 
                        Text("Est: " + step.notOptionalEstimatedCompletionDate)
                            .font(.caption2)
                            .foregroundColor(Color.systemCompatibleTeal)
                    }
                }
            }
            Spacer()
                .frame(width: 10)
            NavigationLink(
                destination: GoalView(
                    goal: step,
                    pasteBoard: pasteBoard
                )
            ) {}
                .frame(maxWidth: 20)
        }
        // This disables the default tap behavior for subviews...Wierd f
//        .gesture(
//            LongPressGesture(minimumDuration: 0.5)
//                .onEnded { _ in
//                    isEditMode.toggle()
//                }
//        )
        .accessibilityIdentifier("goal_cell_\(index)")
    }

}

struct GoalCell_Previews: PreviewProvider {
    static var previews: some View {
        GoalCell(step: .constant(.start), searchText: "", index: 2, pasteBoard: GoalPasteBoard())
    }
}
