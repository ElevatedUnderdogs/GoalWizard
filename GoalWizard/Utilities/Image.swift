//
//  Image.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/12/23.
//

import SwiftUI

extension Image {

    func standard(side: CGFloat = 24) -> some View {
        resizable()
        .frame(width: side, height: side)
        .aspectRatio(contentMode: .fit)
    }

    static var house: some View {
        Image(systemName: "house.fill")
            .standard()
            .accessibilityIdentifier("Home Button")
    }

    static var paste: some View {
        Image(systemName: "doc.on.clipboard.fill")
            .standard()
            .accessibilityIdentifier("paste Button")
    }

    static var cut: some View {
        Image(systemName: "scissors.circle.fill")
            .standard()
            .accessibilityIdentifier("cut Button")
    }

    static var search: some View {
        Image(systemName: "magnifyingglass")
            .standard()
            .accessibilityIdentifier("Search Button")
    }

    static var add: some View {
        Image(systemName: "plus.circle.fill")
            .standard()
            .accessibilityIdentifier("Add Button")
    }

    static var edit: some View {
        Image(systemName: "pencil.circle")
            .standard()
            .aspectRatio(contentMode: .fit)
    }

    static var openaiBolt: some View {
        Image(systemName: "bolt.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
            .padding()
    }

    static var openaiWizard: some View {
        Image("goalWizardGenicon")
            .resizable()
            .cornerRadius(15)
            .frame(width: 35, height: 30)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
    }
}
