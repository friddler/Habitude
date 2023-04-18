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
    
    
    func delete(index: Int){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = habits[index]
        if let id = habit.id {
            habitsRef.document(id).delete()
        }
        
    }
    
    func toggleItem(habit: Habit){

        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        if let id = habit.id {
            habitsRef.document(id).updateData(["done" : !habit.done])
        }
    }
    
    func saveToFirestore(habitName: String){
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = Habit(name: habitName)
        do {
            try habitsRef.addDocument(from: habit)
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
