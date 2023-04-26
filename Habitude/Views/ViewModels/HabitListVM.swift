//
//  HabitListVM.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import Foundation
import Firebase
import FirebaseFirestore

class HabitListVM : ObservableObject {
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    
    @Published var habits = [Habit]()
    var lastToggled = [String: Date]()
    
    
    
    func delete(habit: Habit){
        
        guard let user = auth.currentUser else {return}
        guard let habitIndex = habits.firstIndex(of: habit) else {return}
        
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        if let id = habit.id {
            habitsRef.document(id).delete()
        }
        
        habits.remove(at: habitIndex)
    }
    
    func toggleItem(habit: Habit){
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        guard let id = habit.id else {
            return // don't update if the habit has no ID
        }
        
        if let lastToggled = lastToggled[id], Calendar.current.isDate(Date(), inSameDayAs: lastToggled) {
            print("already toggled today")
            return // don't update if the habit has been toggled today
        }
        
        if !habit.isTapped {
            // If the habit has not been tapped yet, set isTapped to true and update the progress and streak accordingly
            let newProgress = 1.0 / 66.0 // update progress to 1/66
            let newStreak = 1 // set streak to 1
            habitsRef.document(id).updateData(["progress": newProgress, "streak": newStreak, "isTapped": true])
            lastToggled[id] = Date() // update the last toggling time for the habit
            return
        }
        
        // If the habit has already been tapped, update the streak and progress
        let newStreak = habit.isTapped || habit.streak == 0 ? habit.streak + 1 : 0 // increase the streak if habit is tapped or if it's the first time habit, else reset
        let newProgress = Float(newStreak) / 66.0 // update the progress
        let newDone = newStreak == 66 ? true : false
        
        habitsRef.document(id).updateData(["done" : newDone, "streak": newStreak, "progress": newProgress, "isTapped": true])
        lastToggled[id] = Date() // update the last toggling time for the habit
        
    }

    func saveToFirestore(habitName: String, habitDate: Date) {
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = Habit(name: habitName, days: [0])
        //, habitDate: habitDate
        do {
           let _ = try habitsRef.addDocument(from: habit)
        } catch {
            print("error saving to db")
        }
    }
    
    func listenToFirestore(){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        habitsRef.addSnapshotListener(){
            snapshot, err in
            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.habits.removeAll()
                for document in snapshot.documents {
                    do {
                        let habit = try document.data(as: Habit.self)
                        self.habits.append(habit)
                    } catch {
                        print("error reading from db")
                    }
                    
                }
                
            }
        }
    }
    
    
}
