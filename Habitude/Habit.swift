//
//  Habit.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import Foundation
import FirebaseFirestoreSwift

struct Habit : Codable, Identifiable, Equatable {
    
    @DocumentID var id : String? // id of document
    var name: String // Stores the name of the habit
    var streak: Int = 0 // Stores the number of days that the habit has been done
    var isTapped : Bool = false // if the habits been tapped
    var progress: Float  = 0 // progressbar value
    var done: Bool = false // if the habit is done, done = true in 66 days
    var days: [Int]
    var lastToggled: Date?
    var habitStarted: Date?
    //var reminder:
    
    
    
}
    /*var habitDate : Date //unformated date
    
    var dateFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var formattedDate: String {
        return dateFormatter.string(from: habitDate)
    }
     */
    
    
    

