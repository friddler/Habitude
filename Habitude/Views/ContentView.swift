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
        if !signedIn {
            SignInView(signedIn: $signedIn)
        } else {
            HabitListView()
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
            Text("Your habbit tracker")
                .padding(.bottom, 30)
            
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
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }
            Button(action: {
                auth.createUser(withEmail: emailText, password: passwordText) { result, error in
                    if error != nil {
                        print("Error creating account")
                    } else {
                        signedIn = true
                    }
                    
                }
            }) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            }
            
        }
    }


struct HabitListView: View {
    
    @StateObject var habitListVM = HabitListVM()
    @State var showAddAlert = false
    @State var newHabitName = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 200))], spacing: 20){
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
                    // action
                }) {
                    Image(systemName: "gear")
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
            }.background(Color.green.opacity(0.2))
        }
        
    }
}
struct RowView: View {
    
    let habit : Habit
    let vm : HabitListVM
    
    var body: some View {
        HStack{
            Text(habit.name)
                .font(.system(size: 18).bold())
                .foregroundColor(.white)
                .frame(width: 130, height: 130)
                .padding(15)
                .background(Circle().foregroundColor(Color.green))
                
            /*
            Button(action: {
                vm.toggleItem(habit: habit)
                
            }) {
                Image(systemName: habit.done ? "trophy.circle" : "circle")
                    .padding()
                    .foregroundColor(.green)
            }
             */
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        //HabitListView()
        //SignInView(signedIn: true)
        RowView(habit: Habit(name: "Running"), vm: HabitListVM())
    }
}
