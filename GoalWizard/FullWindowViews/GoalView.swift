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
import Dispatch

var isDebug: Bool {
    var result = false
#if DEBUG
    result = true
#endif
    return result
}

struct GoalView: View {

    @ObservedObject var goal: Goal
    @State var showSearchView = false
    @State var flattened = false
    @State var searchText: String = ""
    @State var modifyState: ModifyState?
    @State var buttonState: ButtonState = .normal
    private(set) var pasteBoard: GoalPasteBoard
    @Environment(\.presentationMode) var presentationMode

    // Add an initializer that accepts a Goal and a GoalPasteBoard
    init(goal: Goal, pasteBoard: GoalPasteBoard) {
        self.goal = goal
        self.pasteBoard = pasteBoard
    }

    var filteredSteps: (incomplete: [Goal], completed: [Goal]) {
        goal.subGoals.filteredSteps(with: searchText, flatten: flattened)
    }

    // Top section
    func delete(impcomplete offsets: IndexSet) {
        Goal.context.deleteGoal(goals: offsets.map { filteredSteps.incomplete[$0] })
    }

    // bottom section
    func delete(complete offsets: IndexSet) {
        Goal.context.deleteGoal(goals: offsets.map { filteredSteps.completed[$0] })
    }

    // swiftlint: disable multiple_closures_with_trailing_closure
    var body: some View {
        VersionBasedNavigationStack {
            VStack {
                HStack {
                    if !goal.topGoal && isDebug {
#if os(macOS)
#else
                        Button(action: {
                            // Tap home button.
                            print("home")
                        }) {
                            Image.house
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
#endif
                    }
                    Spacer()
                    if goal.stepCount > 0 {
                        if flattened {
                            Button(action: {
                                flattened.toggle()
                                UIApplication.matchIconToMode()
                            }) {
                                VStack {
                                    Image.tree
                                    Text("Tree")
                                }
                            }.buttonStyle(SkeuomorphicButtonStyle())
                        } else {
                            Button(action: {
                                flattened.toggle()
                                UIApplication.matchIconToMode()
                            }) {
                                VStack {
                                    Image.flattened
                                    Text("Flatten")
                                }
                            }.buttonStyle(SkeuomorphicButtonStyle())
                        }
                    }

                    if let pasteGoal = pasteBoard.cutGoal {
                        Button(action: {
                            pasteGoal.isUserMarkedForDeletion = false
                            goal.add(sub: pasteGoal)
                            pasteBoard.cutGoal = nil
                            UIApplication.matchIconToMode()
                        }) {
                            // paste mode.
                            HStack {
                                VStack {
                                    Text("Paste").font(.footnote)
                                    if let name = pasteBoard
                                        .cutGoal?
                                        .notOptionalTitle
                                        .components(separatedBy: " ")
                                        .first {
                                        Text(name + "...").font(.footnote)
                                    }
                                }
                                Image.paste
                            }
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    } else if !goal.topGoal {

                        // cutmode == true and goal is not topGoal.
                        Button(action: {
                            pasteBoard.cutGoal = goal.cutOut()
                            presentationMode.wrappedValue.dismiss()
                            UIApplication.matchIconToMode()
                        }) {
                            Image.cut
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    }
                    Button(action: {
                        // Tap the search view button.
                        showSearchView.toggle()
                        UIApplication.matchIconToMode()
                    }) {
                        Image.search
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())
                    Button(action: { modifyState = .add }) { Image.add }
                    .buttonStyle(SkeuomorphicButtonStyle())
                }
                .padding(.horizontal)

                if showSearchView {
                    // We can reach this by tapping the search button.
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                        .accessibilityIdentifier("Search TextField")
                }
                if filteredSteps.incomplete.isEmpty && filteredSteps.completed.isEmpty && goal.topGoal {
                    Button(action: { modifyState = .add }) {
                        HStack {
                            Image.add
                            Text("Add a goal!")
                        }
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())
                    .padding()
                }
                List {
                    if goal.topGoal {
                        Section(
                            header: VStack(
                                content: {
                                    Text(goal.notOptionalTitle)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                    GreenGlowingText(text: goal.completedText)
                                        .font(Font.caption2)
                                }
                            )
                        ) {}
                    } else if goal.subGoals.isEmpty {
                        Section(
                            header: HStack(alignment: .center) {
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
                                            estimatedTime: goal.daysEstimate,
                                            importance: goal.importance
                                        )
                                    }
                                Spacer()
                                    .frame(width: 20)
                                Button(action: { modifyState = .edit }) { Image.edit }
                                if buttonState == .normal && isDebug {
                                    // Make a ui test for this and record the response!.
                                    Button(action: {
                                        buttonState = .loading
                                        goal.gptAddSubGoals { _ in
                                            buttonState = .hidden
                                        }
                                        UIApplication.matchIconToMode()
                                    }) {
                                        Image.openaiWizard
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
                        ) {}

                    } else {
                        // In a UI Test go to a step Goal View then add a step goal
                        Section(
                            header: VStack(spacing: 9) {
                                HStack {
                                    Text(goal.notOptionalTitle)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Button(action: { modifyState = .edit }) { Image.edit }
                                    Spacer()
                                        .frame(width: 10)
                                }
                                HStack {
                                    GreenGlowingText(text: goal.completedText)
                                        .font(Font.caption2)
                                    Spacer()
                                }
                                HStack {
                                    ProgressBar(value: goal.progress)
                                        .frame(height: 20)
                                        .padding(.trailing, 10)
                                    Text(goal.notOptionalProgressPercentage)
                                        .padding(.trailing, 10)
                                }
                            }
                        ) {}
                    }

                    if !filteredSteps.incomplete.isEmpty {
                        Section(header: Text("Incomplete")) {
                            ForEach(Array(
                                filteredSteps.incomplete.enumerated()),
                                    id: \.1.id
                            ) { index, step in
                                // Tap a goal cell in the incompleted section (needs a completed)
                                GoalCell(
                                    step: .constant(step),
                                    pathPresentation: flattened ? .partial : nil,
                                    searchText: searchText,
                                    index: index,
                                    // passed for navigation from the cell.
                                    pasteBoard: pasteBoard
                                )
                                .accessibilityIdentifier("goal_cell_\(index)")
                            }
                            .onDelete(perform: delete(impcomplete:))
                        }
                    }

                    if !filteredSteps.completed.isEmpty {
                        Section(header: GreenGlowingText(text: "Completed")) {
                            ForEach(Array(
                                filteredSteps.completed.enumerated()),
                                    id: \.1.id
                            ) { index, step in
                                // tap a goal cell in the completed section.
                                GoalCell(
                                    step: .constant(step),
                                    pathPresentation: flattened ? .partial : nil,
                                    searchText: searchText,
                                    index: index,
                                    pasteBoard: pasteBoard
                                )
                                .accessibilityIdentifier("goal_cell_\(index)")
                            }
                            .onDelete(perform: delete(complete:))
                        }
                    }
                }
                .accessibilityIdentifier("Goal List")
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
        // swiftlint: enable multiple_closures_with_trailing_closure
    }
}
var didIt: Bool = false

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // I can reach this with a GoalView ui test.
        GoalView(goal: Goal.start, pasteBoard: GoalPasteBoard())
    }
}
