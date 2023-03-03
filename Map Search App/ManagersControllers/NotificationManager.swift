//
//  NotificationModel.swift
//  Map Search App
//
//  Created by Константин Малков on 27.02.2023.
//

import UIKit
import UserNotifications

final class WeatherNotification {
    
    static let shared = WeatherNotification()
    
    public func requestNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("User allowed to send him notification")
            } else if let error = error {
                print("error occurred \(error)")
            }
        }
    }
    
    
    public func callNotificationCenter(data: WeatherDataAPI,current: Date){
        let minTemp = Int(data.current.temp_c) // средняя температура за сутки
        let condition = data.current.condition.text //условия погоды
//        let date = data.current.last_updated //дата обновления
//        let convertedDate = WeatherModel.shared.convertStringToDate(date: current)
        let content = UNMutableNotificationContent()
        content.title = "Уведомление о погодных условиях"
        content.subtitle = "Сегодня ожидается средняя температура \(minTemp), \(condition)"
        content.sound = .defaultRingtone
        content.categoryIdentifier = "userIdentifier"
        content.userInfo = ["example":"information"]
        let identifier = "notificationIden"
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day,.month,.hour,.minute,.second], from: current)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error saving notification \(error.localizedDescription)")
            }
        }
    }
}

extension Date {
    func adding(days: Int) -> Date? {
        var comp = DateComponents()
        comp.day = days
        
        return Calendar.current.date(byAdding: comp, to: self)
        
    }
}
