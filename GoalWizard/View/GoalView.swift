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
    @State private var activeLink: UUID?

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())

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

                Text(goal.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                if showSearchView {
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
                }

                List {
                    ForEach(filteredSteps) { step in
                        HStack {
                            if searchText.isEmpty {
                                Text("\(goal.steps.firstIndex(of: step)! + 1). \(step.title)")
                            } else {
                                Text("\(step.title)")
                            }
                            if step.steps.count > 0 {
                                Text("(\(step.steps.count) sub-goals)")
                            } else {
                                RadioButton(isChecked: step.completed)
                            }
                            
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.blue)
                                .background(NavigationLink("", destination: GoalView(goal: step)).opacity(0).frame(width: 0, height: 0))
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.top)

                Spacer()
            }
        #if os(iOS)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        #endif
            .sheet(isPresented: $showModal) {
                AddGoalView(parentGoal: goal)
            }
        }
    }

    var filteredSteps: [Goal] {
        if searchText.isEmpty {
            return goal.steps
        } else {
            return goal.steps.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(goal: Goal(title: "All Goals"))
    }
}
