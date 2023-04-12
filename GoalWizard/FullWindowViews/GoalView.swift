//
//  ContentView.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import SwiftUI
import CoreData
import Callable
import CommonExtensions
import Foundation
import Dispatch

struct GoalView: View {
    
    @ObservedObject var goal: Goal
    @State var showSearchView = false
    @State var searchText: String = ""
    @State private var modifyState: ModifyState? = nil
    @State var buttonState: ButtonState = .normal

    var filteredSteps: (incomplete: [Goal], completed: [Goal]) {
        let filteredGoals: [Goal]

        if searchText.isEmpty {
            filteredGoals = goal.steps.goals
        } else {
            filteredGoals = goal.steps.goals.filter { goal in
                goal.title?.lowercased().contains(searchText.lowercased()) == true
            }.compactMap { $0 }
        }

        let incompleteGoals = filteredGoals
            .filter { $0.progress < 1 }
            .sorted { lhs, rhs -> Bool in
                if lhs.progress == rhs.progress {
                    return lhs.daysLeft < rhs.daysLeft
                }
                return lhs.progress > rhs.progress
            }

        let completedGoals = filteredGoals.filter { $0.progress == 1 }
        return (incomplete: incompleteGoals, completed: completedGoals)
    }

    func deleteGoals(offsets: IndexSet, filteredGoals: [Goal]) {
         let goalMatch: Goal? = offsets.map { filteredGoals[$0] }.first
         let stepIndicesTodelete = IndexSet(goal.steps.goals.enumerated().filter { $0.1 == goalMatch }.map(\.offset))
         for index in stepIndicesTodelete {
             assert((goal.steps?.object(at: index) as? Goal)?.title == goalMatch?.title)
         }
         Goal.context.deleteGoal(atOffsets: stepIndicesTodelete, goal: goal)
     }

     func delete(impcomplete offsets: IndexSet) {
         deleteGoals(offsets: offsets, filteredGoals: filteredSteps.incomplete)
     }

     func delete(complete offsets: IndexSet) {
         deleteGoals(offsets: offsets, filteredGoals: filteredSteps.completed)
     }

    var body: some View {
        VersionBasedNavigationStack {
            VStack {
                HStack {
                    if !goal.topGoal {
                    #if os(macOS)
                    #else
                        Button(action: {
                          print("home")
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    #endif
                    }
                    Spacer()

                    Button(action: {
                        showSearchView.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())

                    Button(action: {
                        modifyState = .add
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())
                }
                .padding(.horizontal)

                if goal.topGoal {
                    Text(goal.notOptionalTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                } else if goal.steps.isEmpty {
                    HStack(alignment: .center) {
                        Text(goal.notOptionalTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        Spacer()
                            .frame(width: 20)
                        Image(systemName: goal.thisCompleted ? "largecircle.fill.circle" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                goal.thisCompleted.toggle()
                                NSPersistentContainer
                                    .goalTable
                                    .viewContext
                                    .updateGoal(
                                        goal: goal,
                                        title: goal.notOptionalTitle,
                                        estimatedTime: goal.daysEstimate
                                    )
                            }
                        Spacer()
                            .frame(width: 20)
                        Button(action: {
                            modifyState = .edit
                        }) {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fit)
                        }
                        if buttonState == .normal {
                            Button(action: {
                                buttonState = .loading
                                goal.gptAddSubGoals { error in
                                    buttonState = .hidden
                                }
                            }) {
                                Image(systemName: "bolt.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
                            }
                        } else if buttonState == .loading {
                            ProgressView()
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            Spacer()
                                .frame(width: 20)
                            Text(goal.notOptionalTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                            Spacer()
                            Button(action: {
                                modifyState = .edit
                            }) {
                                Image(systemName: "pencil.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .aspectRatio(contentMode: .fit)
                            }
                            Spacer()
                                .frame(width: 20)
                        }
                        HStack {
                            ProgressBar(value: goal.progress)
                                .frame(height: 20)
                                .padding(.leading, 20)
                                .padding(.trailing, 10)
                            Text(goal.progressPercentage ?? "")
                                .padding(.trailing, 10)
                        }
                    }
                }
                if showSearchView {
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                }
                List {
                    if !filteredSteps.incomplete.isEmpty {
                        Section(header: Text("Incomplete")) {
                            ForEach(Array(
                                filteredSteps.incomplete.enumerated()),
                                    id: \.1.id
                            ) { index, step in
                                GoalCell(step: step, searchText: searchText, index: index)
                                    .accessibilityIdentifier(step.notOptionalTitle + " goal cell")

                            }
                            .onDelete { indexSet in
                                delete(impcomplete: indexSet)
                            }
                        }
                    }

                    if !filteredSteps.completed.isEmpty {
                        Section(header: GreenGlowingText(text: "Completed")) {
                            ForEach(Array(
                                filteredSteps.completed.enumerated()),
                                    id: \.1.id
                            ) { index, step in
                                GoalCell(step: step, searchText: searchText, index: index)
                                    .accessibilityIdentifier(step.notOptionalTitle + " goal cell")
                            }
                            .onDelete { indexSet in
                                delete(complete: indexSet)
                            }
                        }
                    }
                }
                .padding(.top)
                Spacer()
            }
#if os(iOS)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(goal.topGoal)
#endif
            .sheet(
                item: $modifyState,
                onDismiss: {
                    modifyState = nil
                }
            ) { state in
                switch state {
                case .edit:
                    EditGoalView(goal: goal)
                case .add:
                    AddGoalView(parentGoal: goal)
                }
            }
#if os(macOS)
        .frame(minWidth: 200, maxWidth: 250)
#endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(goal: Goal.start)
    }
}
