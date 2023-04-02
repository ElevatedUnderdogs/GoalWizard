//
//  ContentView.swift
//  GoalWizard
//
//  Created by Scott Lydon on 3/31/23.
//

import SwiftUI

struct GoalView: View {
    
    @ObservedObject var goal: Goal
    @State var showModal = false
    @State var showSearchView = false
    @State var searchText: String = ""

    @State var navigationLinkIsActive : Bool = false
    @Binding var navigationLinkIsActiveBinding : Bool

    var filteredSteps: [Goal] {
        if searchText.isEmpty {
            return goal.steps
        } else {
            return goal.steps.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    if !goal.topGoal {
                        Button(action: {
                            self.navigationLinkIsActiveBinding = false
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
                        showModal.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())
                }
                .padding(.horizontal)

                if goal.topGoal && goal.steps.isEmpty {
                    Text(goal.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                } else if goal.steps.isEmpty {
                    HStack(alignment: .center) {
                        Text(goal.title)
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
                            }
                    }
                } else {
                    VStack {
                        Text(goal.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        HStack {
                            ProgressBar(value: goal.progress)
                                .frame(height: 20)
                                .padding(.leading, 20)
                                .padding(.trailing, 10)
                            Text(goal.progressPercentage)
                                .padding(.trailing, 10)
                        }
                    }
                }

                if showSearchView {
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                }
                List(filteredSteps) { step in
                    HStack {
                        VStack {
                            if searchText.isEmpty {
                                Text("\(goal.steps.firstIndex(of: step)! + 1). \(step.title)")
                                    .font(.title2)
                            } else {
                                Text("\(step.title)")
                            }
                            Spacer()
                            Text("(\(step.steps.count) sub-goals)")
                                .font(.caption2)
                        }
                        Spacer()
                        NavigationLink(
                            destination: GoalView(
                                goal: step,
                                navigationLinkIsActiveBinding: self.$navigationLinkIsActive),
                            isActive: self.$navigationLinkIsActive
                        ) {}
                    }
                }
                .padding(.top)
                Spacer()
            }
#if os(iOS)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(goal.topGoal)
#endif
            .sheet(isPresented: $showModal) {
                AddGoalView(parentGoal: goal)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(goal: Goal(title: "All Goals"), navigationLinkIsActiveBinding: .constant(true))
    }
}
