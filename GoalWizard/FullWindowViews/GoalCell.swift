//
//  GoalCell.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/10/23.
//

import SwiftUI
import CommonExtensions

enum PathPresentation {
    case full
    case partial
}

struct GoalCell: View {
    @Binding var step: Goal

    /// Set to nil for tree mode, a value for flattened.
    @State var pathPresentation: PathPresentation? {
        didSet {
            debugPrint("set path to: \(pathPresentation)")
        }
    }
    let searchText: String
    let index: Int
    var pasteBoard: GoalPasteBoard

    var body: some View {
        HStack { // For accessibility
            VStack {
                if let presentation = pathPresentation {
                    switch presentation {
                    case .full:
                        Button {
                            pathPresentation = .partial
                        } label: {
                            HStack {
                                Text(step.fullAncestorPathSanzFirst)
                                    .font(.caption2)
                                    .foregroundColor(Color.hierarchyPink)
                                Spacer()
                            }
                        }
                    case .partial:
                        Button {
                            pathPresentation = .full
                        } label: {
                            HStack {
                                Text(step.shortenedAncesterPath)
                                    .font(.caption2)
                                    .foregroundColor(Color.hierarchyPink)
                                Spacer()
                            }
                        }
                    }
                }

                HStack {
                    if searchText.isEmpty {
                        Text("\(index + 1).").font(.title2)
                    }
                    ProgressBar(value: step.progress)
                        .frame(height: 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                    Text(step.notOptionalProgressPercentage)
                }
                HStack {
                    Text(step.notOptionalTitle).font(.title2)
                    Spacer()
                }
                Spacer().frame(height: 10)
                HStack(alignment: .top) {
                    /// When flattened we don't need to show subGoals.
                    let isTree = pathPresentation == nil
                    if isTree {
                        Text("\(step.subGoalCount) sub-goals")
                            .font(.caption2)
                            .foregroundColor(Color.systemCompatibleTeal)
                        Spacer()
                    }

                    if step.isCompleted {
                        HStack {
                            Text(step.lastDateCompletedText)
                                .font(.caption2)
                                .foregroundColor(.green)
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("Est: " + step.notOptionalEstimatedCompletionDate)
                            .font(.caption2)
                            .foregroundColor(Color.systemCompatibleTeal)
                    }
                    if !isTree {
                        Spacer()
                    }
                }
                if let importance = step.importance?.decimal, importance != 1 {
                    HStack {
                        if let pathPresentation {
                            Text("Branch importance: \(step.accumulatedImportance.roundedTo(digit: 2).string)")
                                .font(.caption2)
                                .foregroundColor(Color.systemCompatibleTeal)
                        } else {
                            Text("Importance: \(importance.roundedTo(digit: 2).string)")
                                .font(.caption2)
                                .foregroundColor(Color.systemCompatibleTeal)
                        }
                        Spacer()
                        if let createdString = step.createdDate?.typical {
                            Text("created: \(createdString)")
                                .font(.caption2)
                                .foregroundColor(Color.systemCompatibleTeal)
                        }
                    }
                }
            }
            Spacer().frame(width: 10)
            NavigationLink(
                destination: GoalView(goal: step, pasteBoard: pasteBoard)
            ) {}
                .frame(maxWidth: 20)
        }
        // LongPressGesture disables the default tap behavior for subviews...Wierd
        .accessibilityIdentifier("goal_cell_\(index)")
    }

}

struct GoalCell_Previews: PreviewProvider {
    static var previews: some View {
        GoalCell(
            step: .constant(.start),
            pathPresentation: nil,
            searchText: "",
            index: 2,
            pasteBoard: GoalPasteBoard()
        )
    }
}
