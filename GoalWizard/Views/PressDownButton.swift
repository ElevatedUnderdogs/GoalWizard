//
//  PressDownButton.swift
//  GoalWizard
//
//  Created by Scott Lydon on 6/27/23.
//

import SwiftUI

/**
A button that listens to press down, and touch up inside events.

Test permutations:
 - tap fast down up, doesn't trigger press down.
 - tap hold, does trigger press down
 - tap hold, drag finger out, triggers press down, usually doesn't trigger touch up inside.
 - tap hold, touch up inside, triggers press down, then touch up inside.
 */
struct PressDownButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    let onPress: () -> Void
    let onRelease: () -> Void

    @State private var pressCount: Int = 0
    @State private var pressTimer: DispatchSourceTimer?

    init(
        action: @escaping () -> Void,
        onPress: @escaping () -> Void,
        onRelease: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
        self.onPress = onPress
        self.onRelease = onRelease
    }

    var body: some View {
        Button(action: action) {
            content()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    debugPrint("on change")
                    pressCount += 1
                    if pressCount > 2 {
                        onPress()
                    }

                    pressTimer?.cancel()
                    pressTimer = startTimer()
                }
                .onEnded { _ in
                    pressTimer?.cancel()
                    if pressCount > 2 {
                        onRelease()
                    }
                    pressCount = 0
                }
        )
    }

    private func startTimer() -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + .milliseconds(500), leeway: .milliseconds(10))
        timer.setEventHandler(handler: onPress)
        timer.resume()
        return timer
    }
}
