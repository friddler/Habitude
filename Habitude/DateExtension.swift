//
//  DateExtension.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-05-04.
//

import Foundation

extension Date {
    func isWithinSame(component: Calendar.Component, as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([component], from: self)
        let components2 = calendar.dateComponents([component], from: otherDate)

        switch component {
        case .day:
            return components1.day == components2.day
        case .weekOfYear:
            return components1.weekOfYear == components2.weekOfYear && components1.year == components2.year
        case .month:
            return components1.month == components2.month && components1.year == components2.year
        case .year:
            return components1.year == components2.year
        default:
            return false
        }
    }
}
