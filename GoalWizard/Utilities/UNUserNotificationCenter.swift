//
//  UNUserNotificationCenter.swift
//  GoalWizard
//
//  Created by Scott Lydon on 7/4/23.
//

import UserNotifications

extension UNUserNotificationCenter {

    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        add(request) { (error) in
            self.getPendingNotificationRequests { requests in
                print(requests.map(\.identifier))
            }
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    func updateNotification(id: String, title: String, body: String, date: Date) {
        // Remove the existing notification
        removeNotification(id: id)

        // Schedule the new notification
        scheduleNotification(id: id, title: title, body: body, date: date)
    }

    func removeNotification(id: String) {
        removeDeliveredNotifications(withIdentifiers: [id])
    }

    func fetchReminders(with identifiers: [String], completion: @escaping (([String: Date]) -> Void)) {
        getPendingNotificationRequests { (requests) in
            var reminderDates = [String: Date]()
            for request in requests {
                if identifiers.contains(request.identifier),
                   let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    reminderDates[request.identifier] = date
                }
            }
            DispatchQueue.main.async {
                completion(reminderDates)
            }
        }
    }
}
