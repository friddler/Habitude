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
    
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email, password: password) { [self] result, error in
            if error != nil {
                print("Error signing in: \(String(describing: error?.localizedDescription))")
                //alertMessage = "Error signing in. Do you have the correct credentials?"
                //showAlert = true
            } else {
                signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String){
        auth.createUser(withEmail: email, password: password) { [self] result, error in
            if error != nil {
                print("Error creating account")
                // alertMessage = "Error while creating account. Please try again"
                // showAlert = true
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
