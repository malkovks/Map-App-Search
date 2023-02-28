//
//  NotificationModel.swift
//  Map Search App
//
//  Created by Константин Малков on 27.02.2023.
//

import UIKit
import UserNotifications

class WeatherNotification {
    
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
    
    public func callNotificationCenter(data: WeatherDataAPI){
        let center = UNUserNotificationCenter.current()
        
        let minTemp = Int(data.current.temp_c) // средняя температура за сутки
        let condition = data.current.condition.text //условия погоды
        let date = data.current.last_updated //дата обновления
        
        
        let content = UNMutableNotificationContent()
        content.title = "Уведомление о погодных условиях"
        content.subtitle = "Сегодня ожидается средняя температура \(minTemp), \(condition)"
        content.sound = .defaultRingtone
        content.categoryIdentifier = "userIdentifier"
        content.userInfo = ["example":"information"]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let testDate = Date() + 5
        let convertDate = data.current.last_updated
    }
    
    
    
}
