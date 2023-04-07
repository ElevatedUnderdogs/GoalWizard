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

enum ModifyState: Int, Identifiable {
    case edit, add
    var id: Int { rawValue }
}

// MARK: - Goal
struct GoalStruct: Codable {
    let title: String
    let daysEstimate: Int
    let steps: [GoalStruct]
}


struct OpenAIResponse<T: Codable>: Codable {
    let choices: [Choice<T>]
    let id: String
    let model: String
    let usage: Usage
    let object: String
    let created: TimeInterval
}

struct Choice<T: Codable>: Codable {
    let message: Message<T>
    let finishReason: String?
    let index: Int
}

struct Message<T: Codable>: Codable {
    let content: String
    let role: String

    func decodedContent() throws -> T {
        guard let data = content.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct Usage: Codable {
    let totalTokens: Int
    let completionTokens: Int
    let promptTokens: Int

    private enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
    }
}

enum OpenAIError: Error {
    case invalidResponse
}

// MARK: - Choices
struct Choices: Codable {
    let thisSteps: [ThisStep]
}

extension Choices {
    var goals: [Goal] {
        var result = [Goal]()
        for thisStep in thisSteps {
            let goal = Goal(context: NSPersistentContainer.goalTable.viewContext)
            goal.title = thisStep.title
            goal.daysEstimate = Int64(thisStep.daysEstimate)
            goal.progress = 0.0
            goal.topGoal = false
            goal.parent = nil

            var subGoals = [Goal]()
            for step in thisStep.steps {
                let subGoal = Goal(context: NSPersistentContainer.goalTable.viewContext)
                subGoal.title = step.subtitle
                subGoal.daysEstimate = Int64(step.subdaysEstimate)
                subGoal.progress = 0.0
                subGoal.topGoal = false
                subGoal.parent = goal
                subGoals.append(subGoal)
            }
            goal.steps = NSOrderedSet(array: subGoals)
            result.append(goal)
        }
        return result
    }
}

// MARK: - ThisStep
struct ThisStep: Codable {
    let title: String
    let daysEstimate: Int
    let steps: [Step]
}

// MARK: - Step
struct Step: Codable {
    let subtitle: String
    let subdaysEstimate: Int
}


enum ButtonState {
    case normal
    case loading
    case hidden
}


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
        NSPersistentContainer.goalTable.viewContext.deleteGoal(atOffsets: offsets, goal: goal)
       // goal.delete(at: offsets)
        // Save the changes to persistence if needed
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    if !goal.topGoal {
                        Button(action: {
                          print("home")
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
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
                                print(goal.notOptionalTitle)
                                URLRequest.gpt35TurboChatRequest(
                                    messages: .buildUserMessage(
                                        content: .goalTreeFrom(goal: goal.notOptionalTitle)
                                    )
                                ).callCodable { (response: OpenAIResponse<Choices>?) in
                                    print("Callback returned")
                                    DispatchQueue.main.async {
                                        do {
                                            let newGoals = try response?.choices.first?.message.decodedContent().goals ?? []
                                            self.goal.add(subGoals: newGoals)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        buttonState = .hidden
                                    }
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
                    ForEach(filteredSteps.indices, id: \.self) { index in
                        let step = filteredSteps[index]
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
                                        .foregroundColor(Color(UIColor.systemTeal))
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
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                }
                            }
                            Spacer()
                                .frame(width: 10)
                            NavigationLink(
                                destination: GoalView(goal: step)) {}
                                .frame(maxWidth: 20)
                        }
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    isEditMode.toggle()
                                }
                        )
                    }
                    .onMove(perform: isEditMode ? move : nil)
                    .onDelete(perform: delete)
                }
                .padding(.top)
                Spacer()
            }

//            .refreshable {
//                let topGoal = await NSPersistentContainer.goalTable.viewContext.topGoal
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
