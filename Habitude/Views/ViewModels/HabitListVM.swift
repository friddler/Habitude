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
    @Published var completedHabits = [Habit]()
    
    
    func toggleItem(habit: Habit, completion: @escaping () -> Void){
        
        /*
         The completion closure ensures that the progressvalue is only updated after the habit is updated in firebase.
         without the completion escaping, this function runs synchronusly and returns after the setData is called. the prgoressvalue is then being updated before the firestore method is done, which is resulting in displaying wrong data in my view.
         */
        
        guard let user = auth.currentUser else { return }
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        guard let id = habit.id else { return }
        
        let newStreak = habit.isTapped ? habit.streak + 1 : 1
        let newProgress = Float(newStreak) / 66.0
        let newDone = newStreak >= 66
        
        let updatedData: [String: Any] = ["isTapped" : true, "streak": newStreak,
                                          "progress": newProgress, "done": newDone,
                                          "lastToggled": Date()]
        
        habitsRef.document(id).setData(updatedData, merge: true) { error in
            if let error = error {
                print("error updating habit: \(error)")
            } else {
                print("habit updated successfully")
                
                if newDone {
                    if let index = self.habits.firstIndex(where: {$0.id == habit.id}) { //checks if the habit is complete ->
                        let completedHabit = self.habits.remove(at: index) //removes the complete habit from the habits array ->
                        self.completedHabits.append(completedHabit) //appends the complete habit to the array ->
                        habitsRef.document(id).delete() // deletes the habit from firebase
                        self.saveCompleteHabit(habit: completedHabit) //saves the complete habit to a new collection
                    }
                }
                completion()
            }
        }
    }
    
    
    
    func saveCompleteHabit(habit: Habit){
        
        guard let user = auth.currentUser else { return }
        let completeHabitsRef = db.collection("users").document(user.uid).collection("completeHabits")
        
        var completedHabit = habit
        completedHabit.done = true
        
        do {
            let _ = try completeHabitsRef.addDocument(from: completedHabit)
        } catch {
            print("Error saving complete habit: \(error)")
        }
    }
    
    func saveToFirestore(habitName: String, habitStarted: Date) {
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = Habit(name: habitName, days: [0], habitStarted: habitStarted)
        do {
            let _ = try habitsRef.addDocument(from: habit)
        } catch {
            print("error saving habit")
        }
    }
    
    func listenToCompletedHabitsFirestore(){
        
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("completeHabits")
        
        habitsRef.addSnapshotListener(){
            snapshot, err in
            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.completedHabits.removeAll()
                for document in snapshot.documents {
                    do {
                        let habit = try document.data(as: Habit.self)
                        self.completedHabits.append(habit)
                    } catch {
                        print("error reading complete habits from db")
                    }
                    
                }
                
            }
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
    
    func delete(habit: Habit){
        
        guard let user = auth.currentUser else {return}
        guard let habitIndex = habits.firstIndex(of: habit) else {return}
        
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        if let id = habit.id {
            habitsRef.document(id).delete()
        }
        
        habits.remove(at: habitIndex)
    }
    
}

