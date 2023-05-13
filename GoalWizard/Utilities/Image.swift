//
//  Image.swift
//  GoalWizard
//
//  Created by Scott Lydon on 5/12/23.
//

import SwiftUI

extension Image {

    static var house: some View {
        Image(systemName: "house.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("Home Button")
    }

    static var paste: some View {
        Image(systemName: "doc.on.clipboard.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("paste Button")
    }

    static var cut: some View {
        Image(systemName: "scissors.circle.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("cut Button")
    }

    static var search: some View {
        Image(systemName: "magnifyingglass")
            .resizable()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("Search Button")
    }

    static var add: some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("Add Button")
    }

    static var edit: some View {
        Image(systemName: "pencil.circle")
            .resizable()
            .frame(width: 24, height: 24)
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
