//
//  SignInVM.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-19.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    
    @Published var signedIn = false
    
    var auth = Auth.auth()
    
    
    func scheduleDailyNotification(hour: Int, minute: Int, identifier: String, title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email, password: password) { [self] result, error in
            if error != nil {
                print("Error signing in: \(String(describing: error?.localizedDescription))")
            } else {
                signedIn = true
            }
            
            scheduleDailyNotification(hour: 20, minute: 02, identifier: "habitReminder", title: "Habit Reminder", body: "Don't forget to tap your habits to keep your streak!")
        }
    }
    
    func signUp(email: String, password: String){
        auth.createUser(withEmail: email, password: password) { [self] result, error in
            if error != nil {
                print("Error creating account")
            } else {
                signedIn = true
                
            }
        }
        
    }
    func signOut() {
        do {
            try auth.signOut()
            signedIn = false
        } catch {
            print("error signing out")
        }
        
    }
}
