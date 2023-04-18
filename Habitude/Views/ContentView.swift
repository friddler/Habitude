//
//  ContentView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import SwiftUI
import Firebase

struct ContentView : View {
    @State var signedIn = false
    
    var body: some View {
        NavigationView {
            if !signedIn {
                SignInView(signedIn: $signedIn)
            } else {
                HabitListView(signedIn: $signedIn)
            }
        }
    }
}

struct SignInView: View {
    @Binding var signedIn : Bool
    var auth = Auth.auth()
    
    @State var emailText: String = ""
    @State var passwordText: String = ""
    
    var body: some View {
            VStack {
                Spacer()
                Text("Welcome to Habitude")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                Text("Your habbit tracker")
                    .padding(.bottom, 10)
        
                
                TextField("Username", text: $emailText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                SecureField("Password", text: $passwordText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                Button(action: {
                    auth.signIn(withEmail: emailText, password: passwordText) { result, error in
                        if error != nil {
                            print("Error signing in")
                        } else {
                            signedIn = true
                        }
                        
                    }
                }) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                }
                Button(action: {
                    auth.createUser(withEmail: emailText, password: passwordText) { result, error in
                        if error != nil {
                            print("Error creating account")
                        } else {
                            signedIn = true
                            auth.currentUser?.getIDToken(completion: {token, error in
                                if error == nil {
                                    UserDefaults.standard.set(token, forKey: "authToken")
                                }
                            })
                        }
                        
                    }
                }) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }.background(Color.green.opacity(0.3))
        }
    }


struct HabitListView: View {
    
    @StateObject var habitListVM = HabitListVM()
    @State var showAddAlert = false
    @State var newHabitName = ""
    @Binding var signedIn: Bool
    
    var auth = Auth.auth()
    
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 200))], spacing: 10){
                    ForEach(habitListVM.habits) { habit in
                        RowView(habit: habit, vm: habitListVM)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.onDelete { IndexSet in
                        for index in IndexSet {
                            habitListVM.delete(index: index)
                        }
                        
                    }.padding()
                }
            }
            .shadow(radius: 5)
            HStack {
                Button(action: {
                    do {
                       try auth.signOut()
                        signedIn = false
                    } catch {
                        print("error signing out")
                    }
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .padding(.horizontal, 40)
                    
                }
                Spacer()
                Button(action: {
                    showAddAlert = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .padding(.bottom, 10)
                }
                Spacer()
                Button(action: {
                    // action
                    
                }) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .padding(.horizontal, 40)
                }
            }
            .padding(.horizontal)
            .onAppear {
                habitListVM.listenToFirestore()
            }
            .alert("Add", isPresented: $showAddAlert) {
                TextField("Add", text: $newHabitName)
                Button("Add", action: {
                    habitListVM.saveToFirestore(habitName: newHabitName)
                    newHabitName = ""
                })
            }.background(Color.green.opacity(0.4))
        }
        
    }
}
struct RowView: View {
    
    let habit : Habit
    let vm : HabitListVM
    
    var body: some View {
        HStack{
            Button(action: {
                vm.toggleItem(habit: habit)
            }){
                Text(habit.name)
                    .font(.system(size: 18).bold())
                    .foregroundColor(.white)
                    .frame(width: 140, height: 140)
                    .padding(15)
                    .background(RoundedRectangle(cornerRadius: 50).foregroundColor(habit.done ? .green.opacity(0.5) : .red.opacity(0.5)))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //HabitListView()
        //SignInView(signedIn: true)
        //RowView(habit: Habit(name: "Running"), vm: HabitListVM())
    }
}
