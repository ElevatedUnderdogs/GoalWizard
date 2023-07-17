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

// Swiftui can be more expressive with more contents in View body.
// swiftlint: disable type_body_length
struct GoalView: View {

    @ObservedObject var goal: Goal
    @State var showSearchView = false
    @State var flattened = false
    @State var searchText: String = ""
    @State var modifyState: ModifyState?
    @State var buttonState: ButtonState = .normal
    @State var isCutButtonTouchdown: Bool = false
    @State private var showCopiedMessage = false
    private(set) var pasteBoard: GoalPasteBoard
    @Environment(\.presentationMode) var presentationMode

    @GestureState private var isTapped = false

    // Add an initializer that accepts a Goal and a GoalPasteBoard
    init(goal: Goal, pasteBoard: GoalPasteBoard) {
        self.goal = goal
        self.pasteBoard = pasteBoard
    }

    var filteredSteps: (incompletes: [Goal], completed: [Goal]) {
        goal.subGoals.filteredSteps(with: searchText, flatten: flattened)
    }

    // Top section
    func delete(impcomplete offsets: IndexSet) {
        Goal.context.deleteGoal(goals: offsets.map { filteredSteps.incompletes[$0] })
    }

    // bottom section
    func delete(complete offsets: IndexSet) {
        Goal.context.deleteGoal(goals: offsets.map { filteredSteps.completed[$0] })
    }

    // swiftlint: disable multiple_closures_with_trailing_closure
    var body: some View {
        VersionBasedNavigationStack {
            VStack {
                if showSearchView {
                    // We can reach this by tapping the search button.
                    TextField("Search \(goal.notOptionalTitle) steps", text: $searchText)
                        .searchFieldStyle
                }

                if isCutButtonTouchdown {
                    Text(goal.cutInstructions)
                }
                // MARK: - Table/List
                List {
                    if goal.topGoal && !showSearchView {
                        Section(
                            header: VStack {
                                Text(goal.notOptionalTitle)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                GreenGlowingText(text: goal.completedText)
                                    .font(Font.caption2)
                            }
                        ) {}
                    } else if goal.subGoals.isEmpty && !showSearchView {
                        Section(
                            header:
                                VStack(alignment: .center) {
                                    Text(goal.notOptionalTitle)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    HStack {
                                        Spacer()
                                            .frame(width: 20)
                                        VStack {
                                            if goal.thisCompleted {
                                                Image.circle(completed: goal.thisCompleted)
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(Color.goalGreen)
                                                GreenGlowingText(text: "Done")
                                            } else {
                                                Image.circle(completed: goal.thisCompleted)
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                Text("Done?")
                                            }
                                        }
                                        .onTapGesture {
                                            goal.thisCompleted.toggle()
                                            if goal.thisCompleted {
                                                goal.completedDates.appendIfUnique(Date())
                                            }
                                            Goal.context.updateGoal(
                                                goal: goal,
                                                title: goal.notOptionalTitle,
                                                estimatedTime: goal.daysEstimate,
                                                importance: goal.importance
                                            )
                                        }
                                        Spacer()
                                            .frame(width: 20)
                                        Button(action: { modifyState = .edit }) {
                                            VStack {
                                                Image.edit
                                                Text("Edit").font(Font.caption2)
                                            }
                                        }
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
                                    // Won't Finish toggle and text field
                                    Toggle(isOn: Binding(
                                        get: { self.goal.wontFixText != nil },
                                        set: {
                                            if $0 {
                                                self.goal.wontFixText = $0 ? (goal.wontFixText ?? "") : nil
                                            } else {
                                                self.goal.wontFixText = nil
                                            }
                                        }
                                    )) {
                                        Text("Won't Finish")
                                    }
                                    .padding()

                                    if goal.wontFixText != nil {
                                        TextField(
                                            "Reason to not finish",
                                            text: Binding(
                                                get: { self.goal.wontFixText ?? "" },
                                                set: {
                                                    if goal.wontFixText == nil && $0 == "" {

                                                    } else {
                                                        goal.wontFixText = $0
                                                    }
                                                }
                                            )
                                        )
                                        .padding()
                                        .border(Color.gray, width: 0.5)
                                    }

                                    // In Motion toggle and date picker
                                    Toggle(isOn: Binding(
                                        get: { self.goal.inMotionFollowUpDate != nil },
                                        set: { self.goal.inMotionFollowUpDate = $0 ? Date.distantFuture : nil }
                                    )) {
                                        Text("In Motion")
                                    }.padding()

                                    if let inMotionFollowUpDate = goal.inMotionFollowUpDate {
                                        DatePicker(
                                            "Select a date",
                                            selection: Binding(
                                                get: { self.goal.inMotionFollowUpDate ?? Date.distantFuture },
                                                set: { newValue in self.goal.inMotionFollowUpDate = newValue }
                                            ),
                                            in: Date()...,
                                            displayedComponents: .date
                                        )
                                        .padding()
                                    }
                                }
                        ) {}

                    } else if !showSearchView {
                        // In a UI Test go to a step Goal View then add a step goal
                        Section(
                            header: VStack(spacing: 9) {
                                HStack {
                                    Text(goal.notOptionalTitle)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Button(action: { modifyState = .edit }) {
                                        VStack {
                                            Image.edit
                                            Text("Edit").font(Font.caption2)
                                        }
                                    }
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
                    if filteredSteps.incompletes.isEmpty && filteredSteps.completed.isEmpty {
                        Button(action: { modifyState = .add }) {
                            HStack {
                                Image.add
                                Text(goal.topGoal ? "Add a goal!": "Add a sub goal.")
                            }
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                        .padding()
                    }
                    if !filteredSteps.incompletes.isEmpty {
                        Section(
                            header: HStack {
                                Button(action: {
                                    // Handle tap action here
                                    debugPrint("Incomplete section tapped!")
                                    self.showCopiedMessage = true
                                    UIPasteboard.general.string = goal.generateSubGoalCopyText()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        self.showCopiedMessage = false
                                    }
                                }) {
                                    Text("Incomplete: \(filteredSteps.incompletes.count)")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                if showCopiedMessage {
                                    GreenGlowingText(text: "Copied")
                                }
                            }
                        ) {
                            ForEach(Array(
                                filteredSteps.incompletes.enumerated()),
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
                .overlay(isCutButtonTouchdown ?
                         RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2) : nil
                )
                .accessibilityIdentifier("Goal List")
                Spacer()

                // MARK: Horizontal Scroll view for buttons.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                        if goal.stepCount > 0 {
                            if flattened {
                                Button(action: {
                                    flattened.toggle()
                                    UIApplication.matchIconToMode()
                                }) {
                                    VStack {
                                        Image.tree
                                        Text("Tree").font(Font.caption2)
                                    }
                                }.buttonStyle(SkeuomorphicButtonStyle())
                            } else {
                                Button(action: {
                                    flattened.toggle()
                                    UIApplication.matchIconToMode()
                                }) {
                                    VStack {
                                        Image.flattened
                                        Text("Flatten").font(Font.caption2)
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
                                VStack {
                                    Image.paste
                                    VStack {
                                        Text("Paste").font(.footnote)
                                        if let name = pasteBoard
                                            .cutGoal?
                                            .notOptionalTitle
                                            .components(separatedBy: " ")
                                            .first {
                                            Text(name.count > 5 ? (String(name.prefix(5)) + "...") : name)
                                                .font(.footnote)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                        } else if !goal.topGoal {
                            PressDownButton {
                                pasteBoard.cutGoal = goal.cutOut()
                                presentationMode.wrappedValue.dismiss()
                                UIApplication.matchIconToMode()
                            } onPress: {
                                isCutButtonTouchdown = true
                            } onRelease: {
                                isCutButtonTouchdown = false
                            } content: {
                                VStack {
                                    Image.cut
                                    Text("Cut").font(.footnote)
                                }
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
                        Button(action: { modifyState = .add }) {
                            VStack {
                                Image.add
                                Text(goal.topGoal ? "Add goal": "Sub")
                                    .font(Font.caption2)
                            }
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    }
                }
            }
#if os(iOS)
            .navigationBarTitle(goal.notOptionalTitleClipped, displayMode: .inline)
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
// swiftlint: enable type_body_length
var didIt: Bool = false

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // I can reach this with a GoalView ui test.
        GoalView(goal: Goal.start, pasteBoard: GoalPasteBoard())
    }
}
