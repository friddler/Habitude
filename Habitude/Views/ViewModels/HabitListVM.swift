//
//  HabitListVM.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import Foundation
import Firebase

class HabitListVM : ObservableObject {
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @Published var habits = [Habit]()
    
    
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
        
        if let id = habit.id { // if the habit has an id
            let newStreak = habit.isTapped ? habit.streak + 1 : 0 // increase the streak if habit is tapped else reset
            let newProgress = Float(newStreak) / 65 // progress is % of 66-day goal, divided by 65 because first day is 0
            let newDone = newStreak == 66 ? true : false // if habit is done, done updates // what happens after???
            habitsRef.document(id).updateData(["done" : newDone, "streak": newStreak, "progress": newProgress, "isTapped": true])
        }
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
