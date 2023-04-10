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
    @State private var isEditMode: Bool = false
    @State var buttonState: ButtonState = .normal

    var filteredSteps: [Goal] {
        if searchText.isEmpty {
            return goal.steps.goals
        } else {
            return goal.steps.goals.filter { goal in
                goal.title?.lowercased().contains(searchText.lowercased()) == true
            }.compactMap { $0 }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        goal.move(fromOffsets: source, toOffset: destination)
        // Remove from persistence if needed
    }

    func delete(at offsets: IndexSet) {
        Goal.context.deleteGoal(atOffsets: offsets, goal: goal)
       // goal.delete(at: offsets)
        // Save the changes to persistence if needed
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
                    ForEach(filteredSteps) { step in
                        HStack {
                            VStack {
                                HStack {
                                    if searchText.isEmpty {
                                        Text("\(goal.steps.goals.firstIndex(of: step)! + 1).")
                                            .font(.title2)
                                    }
                                    ProgressBar(value: step.progress)
                                        .frame(height: 10)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 10)
                                    Text(step.progressPercentage ?? "")
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
                                        Text("Est: " + (step.estimatedCompletionDate ?? ""))
                                            .font(.caption2)
                                            .foregroundColor(Color.systemCompatibleTeal)
                                    }
                                }
                            }
                            Spacer()
                                .frame(width: 10)
                            NavigationLink(
                                destination: GoalView(goal: step)) {}
                                .frame(maxWidth: 20)
                        }
                        // This disables the default tap behavior for subviews...Wierd f
//                        .gesture(
//                            LongPressGesture(minimumDuration: 0.5)
//                                .onEnded { _ in
//                                    isEditMode.toggle()
//                                }
//                        )
                    }
                    .onMove(perform: isEditMode ? move : nil)
                    .onDelete(perform: delete)
                }
                .padding(.top)
                Spacer()
            }

//            .refreshable {
//                let topGoal = await Goal.context.topGoal
//                guard let topGoal else { return }
//                self.goal = topGoal
//            }
         
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


        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(goal: Goal.start)
    }
}
