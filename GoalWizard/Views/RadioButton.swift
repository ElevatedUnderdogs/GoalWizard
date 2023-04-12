//
//  RadioButton.swift
//  GoalWizard
//
//  Created by Scott Lydon on 4/1/23.
//

import SwiftUI

struct RadioButton: View {
    @State var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "largecircle.fill.circle" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

import SwiftUI

struct GreenGlowingText: View {
    var text: String

    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(.green)
                .font(.body)
                .blur(radius: 5)
                .opacity(0.7)

            Text(text)
                .foregroundColor(.green)
                .font(.body)
        }
    }
}

struct ContentView: View {
    var body: some View {
        GreenGlowingText(text: "Glowing Green Text")
            .padding()
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
