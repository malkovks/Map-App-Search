//
//  DateClass.swift
//  Map Search App
//
//  Created by Константин Малков on 03.02.2023.
//

import Foundation

class DateClass {
    static func dateConverter() -> String{
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss"
        format.timeStyle = .medium
        format.dateStyle = .long
        format.timeZone = TimeZone(abbreviation: "UTC+3")
        let stringFormat = format.string(from: date)
        return stringFormat
    }
}
