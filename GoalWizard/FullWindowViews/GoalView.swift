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
    @State var modifyState: ModifyState? = nil
    @State var buttonState: ButtonState = .normal

    var filteredSteps: (incomplete: [Goal], completed: [Goal]) {
        goal.steps.goals.filteredSteps(with: searchText)
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
                            // Tap home button.
                          print("home")
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fit)
                                .accessibilityIdentifier("Home Button")
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    #endif
                    }
                    Spacer()

                    Button(action: {
                        // Tap the search view button.
                        showSearchView.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIdentifier("Search Button")
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())

                    Button(action: {
                        modifyState = .add
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIdentifier("Add Button")
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
                                Goal.context.updateGoal(
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
                            // Make a ui test for this and record the response!.
                            Button(action: {
                                buttonState = .loading
                                goal.gptAddSubGoals { error in
                                    buttonState = .hidden
                                }
                            }) {
#if os(macOS)
                                Image(systemName: "bolt.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding()
#else
                               // Image(systemName: "bolt.circle")
                                Image("goalWizardGenicon")
                                    .resizable()
                                    .cornerRadius(15)
                                    .frame(width: 35, height: 30)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
#endif
                            }
#if os(macOS)
                            .background(Color.clear)
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
#endif
                        } else if buttonState == .loading {
                            ProgressView()
                        }
                    }
                } else {
                    // In a UI Test go to a step Goal View then add a step goal
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
                    // We can reach this by tapping the search button.
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                        .accessibilityIdentifier("Search TextField")
                }
                List {
                    if !filteredSteps.incomplete.isEmpty {
                        Section(header: Text("Incomplete")) {
                            ForEach(Array(
                                filteredSteps.incomplete.enumerated()),
                                    id: \.1.id
                            ) { index, step in
                                // Tap a goal cell in the incompleted section (needs a completed)
                                GoalCell(step: .constant(step), searchText: searchText, index: index)
                                    .accessibilityIdentifier("goal_cell_\(index)")
                            }
                            .onDelete { indexSet in
                                // Might not be worth it, swipe to delete keeps failing in unit tests. perhaps there is a apple provided method for swiping the first cell to the left.
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
                                // tap a goal cell in the completed section.
                                GoalCell(step: .constant(step), searchText: searchText, index: index)
                                    .accessibilityIdentifier("goal_cell_\(index)")
                            }
                            .onDelete { indexSet in
                                // Might not be worth it, swipe to delete keeps failing in unit tests. perhaps there is a apple provided method for swiping the first cell to the left.
                                delete(complete: indexSet)
                            }
                        }
                    }
                }
                .padding(.top)
                .accessibilityIdentifier("Goal List")
                Spacer()
            }
            .onAppear {
                print("lkj lkj lkj lkj ")
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
                        .accessibilityIdentifier("Edit Goal View")
                case .add:
                    AddGoalView(parentGoal: goal)
                        .accessibilityIdentifier("Add Goal View")
                }
            }

#if os(macOS)
            // I would have to force the operating system.
        .frame(minWidth: 200, maxWidth: 250)
#endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // I can reach this with a GoalView ui test.
        GoalView(goal: Goal.start)
    }
}
