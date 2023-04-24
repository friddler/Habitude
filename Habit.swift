//
//  Habit.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import Foundation
import FirebaseFirestoreSwift

struct Habit : Codable, Identifiable {
    
    @DocumentID var id : String? // id of document
    var name: String // Stores the name of the habit
    var streak: Int = 0 // Stores the number of days that the habit has been done
    var isTapped : Bool = false
    var progress: Float  = 0
    var done: Bool = false // if the habit is done in 66 days
    
    var days: [Int]
    //var reminder: Date
    
   
    
//    init(name: String, progress: Float = 0, done: Bool) {
//        self.name = name
//        self.progress = progress
//        self.done = done
//    }
    
    //var unformatedDate : Date
    //var dateformatter = DateFormatter()
    
    /*
    var date : String {
        return dateformatter.string(from: unformatedDate)
    }
    
    
    init(){
        self.unformatedDate = Date()
        dateformatter.dateStyle = .medium
    }
    
    init(date: Date){
        self.unformatedDate = date
        dateformatter.dateStyle = .medium
    }
    
     */
    
    
    
}
