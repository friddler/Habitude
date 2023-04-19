//
//  ContentView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import SwiftUI
import Firebase

struct ContentView : View {
    @StateObject var authVM = AuthViewModel()
    // @State var signedIn = false
    
    var body: some View {
        NavigationView {
            Group {
                if !signedIn {
                    SignInView(authVM: authVM, signedIn: $signedIn)
                } else {
                    HabitListView(authVM: authVM, signedIn: $signedIn)
                }
            }
        }
    }
}

struct SignInView: View {
    
    @ObservedObject var authVM : AuthViewModel
    
    var auth = Auth.auth()
    
    @Binding var signedIn : Bool
    
    @State var emailText: String = ""
    @State var passwordText: String = ""
    
    @State var showAlert = false
    @State var alertMessage: String = ""
    
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
                    authVM.signIn(email: emailText, password: passwordText)
                    
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
                .alert(isPresented: $showAlert, content: {
                    Alert(title: Text("Oopsie.."), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                })
                
                Button(action: {
                    authVM.signUp(email: emailText, password: passwordText)
                    
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
                .alert(isPresented: $showAlert, content: {
                    Alert(title: Text("Oopsie.."), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                })
                
                Spacer()
            }
            .background(Color.green.opacity(0.3))
        }
    }


struct HabitListView: View {
    
    @ObservedObject var authVM : AuthViewModel
    @StateObject var habitListVM = HabitListVM()
    @State var newHabitName = ""
    @State var showAddView = false
    @Binding var signedIn: Bool
    
    var auth = Auth.auth()
    
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 200))], spacing: 10){
                    ForEach(habitListVM.habits) { habit in
                        RowView(habit: habit, vm: habitListVM)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    }.padding()
                }
            }
            .shadow(radius: 5)
            HStack {
                Button(action: {
                    authVM.signOut()
                    signedIn = false
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .padding(.horizontal, 40)
                    
                }
                Spacer()
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .padding(.bottom, 10)
                }
                .sheet(isPresented: $showAddView){
                    AddHabitView(habitListVM: habitListVM)
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
            .background(Color.green.opacity(0.4))
            .onReceive(authVM.$signedIn) {signedIn = $0}
            
            }
        }
    }

struct AddHabitView: View {
    @ObservedObject var habitListVM = HabitListVM()
    @Environment(\.presentationMode) var presentationMode
    @State var habitName = ""
    
    
    var body: some View {
        VStack {
            TextField("Habit:", text: $habitName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
            
            Button("Save") {
                habitListVM.saveToFirestore(habitName: habitName)
                    habitName = ""
                presentationMode.wrappedValue.dismiss()
            }
            .frame(width: 110, height: 20)
            .font(.headline)
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(15)
            
        }
        .navigationBarTitle("Add a new habbit", displayMode: .inline)
        
    }
}
struct RowView: View {
    
    let habit : Habit
    let vm : HabitListVM
    @State var progressValue: Float = 0.0
    
    
    var body: some View {
        ZStack{
            VStack {
                ProgressBar(progress: self.$progressValue)
                    .frame(width: 150.0, height: 150.0)
                    .padding(40.0)
                
                Button(action: {
                    vm.toggleItem(habit: habit)
                    self.updateProgress()
                }) {
                    
                    Text(habit.name)
                        .font(.system(size: 18).bold())
                        .foregroundColor(.green)
                    
                }
                
            }
       }
    }
    
    func updateProgress(){
        self.progressValue = habit.done ? 1.0 : 0.0
    }
}


struct ProgressBar: View {
    @Binding var progress: Float
    
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.green)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)

            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        //HabitListView(signedIn: .constant(true))
        SignInView(authVM: AuthViewModel(), signedIn: .constant(true))
        //RowView(habit: Habit(name: "Running"), vm: HabitListVM())
        //AddHabitView()
    }
}


/*
 .onDelete { IndexSet in
     for index in IndexSet {
         habitListVM.delete(index: index)
     }
 
 
 
 .alert("Add", isPresented: $showAddAlert) {
     TextField("Add", text: $newHabitName)
     Button("Add", action: {
         habitListVM.saveToFirestore(habitName: newHabitName)
         newHabitName = ""
     })
 
 
 
 Button(action: {
     vm.toggleItem(habit: habit)
 }) {
     Text(habit.name)
         .font(.system(size: 18).bold())
         .foregroundColor(.white)
         .frame(width: 140, height: 140)
         .padding(15)
         .background(RoundedRectangle(cornerRadius: 50).foregroundColor(habit.done ? .green.opacity(0.5) : .red.opacity(0.5)))
 */
