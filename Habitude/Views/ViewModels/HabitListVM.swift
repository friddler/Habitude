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
    
    /*
    func delete(index: Int){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = habits[index]
        if let id = habit.id {
            habitsRef.document(id).delete()
        }
        
    }
     */
    
    func toggleItem(habit: Habit){

        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        if let id = habit.id {
            let newStreak = habit.isTapped ? habit.streak + 1 : 0 // om den
            let newProgress = Float(min(newStreak, 66)) / 66
            let newDone = newStreak == 66 ? true : false
            habitsRef.document(id).updateData(["done" : newDone, "streak": newStreak, "progress": newProgress, "isTapped": true])
        }
    }
    
    func saveToFirestore(habitName: String, habitDate: Date) {
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = Habit(name: habitName, days: [0], habitDate: habitDate)
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
