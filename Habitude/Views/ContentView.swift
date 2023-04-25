//
//  ContentView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import SwiftUI
import Firebase

struct ContentView : View {
    
    /*
     StateObject hanterar authVM, den söker efter förändringar och uppdaterar viewn automatiskt. Den hanterar en instans av AuthVM som är : ObservableObject
     I contentView så är authVM ansvarig för att bestämma vilken vy som ska visas beroende på om användaren är inloggad eller inte.
     */
    
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        NavigationView {
            if authVM.signedIn {
                HabitListView(authVM: authVM)
            } else {
                SignInView(authVM: authVM)
            }
        }
    }
}

struct SignInView: View {
    
    //ObservedObject används för att lyssna på förändringar som sker i en instans av authVM
    //och uppdaterar automatiskt viewn när den ändras
    
    @ObservedObject var authVM : AuthViewModel
    
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
                //                    if emailText.isEmpty || passwordText.isEmpty {
                //                        authVM.signIn(email: emailText, password: passwordText)
                //                    } else {
                //                        alertMessage = "Error signing in. Do you have the correct credentials?"
                //                        showAlert = true
                //                    }
                
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
                //                    if emailText.isEmpty || passwordText.isEmpty {
                //                        alertMessage = "Error while creating account. Please try again"
                //                        showAlert = true
                //                    } else {
                //                        authVM.signUp(email: emailText, password: passwordText)
                //                    }
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
    @State var showSummaryView = false
    
    
    var auth = Auth.auth()
    
    
    var body: some View {
            VStack {
                Text("Frida")
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200)), GridItem(.adaptive(minimum: 200))], spacing: 5){
                        ForEach(habitListVM.habits) { habit in
                            RowView(habit: habit, vm: habitListVM)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        }
                        .padding()
                        
                    }
                    
                }
                .shadow(radius: 5)
                HStack {
                    Button(action: {
                        authVM.signOut()
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
                        showSummaryView = true
                    }) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.white)
                            .cornerRadius(100)
                            .padding(.horizontal, 40)
                    }
                    .fullScreenCover(isPresented: $showSummaryView) {
                        SummaryHabitView(habitListVM: habitListVM)
                    }
                      
                    
                }
                .padding(.horizontal)
                .onAppear {
                    habitListVM.listenToFirestore()
                }
                .background(Color.green.opacity(0.4))
                
            }
            .background(Color.white)
        }

}


struct AddHabitView: View {
    
    @ObservedObject var habitListVM = HabitListVM()
    @Environment(\.presentationMode) var presentationMode
    @State var habitName = ""
    @State var habitDate: Date = Date.now
    
    
    var body: some View {
        VStack {
            Form {
                Section("Habit name"){
                    TextField("Habit:", text: $habitName)
                }
                
                Section("Habit started: "){
                    DatePicker("I started on", selection: $habitDate, displayedComponents: [.date])
                        .accentColor(Color.green)
                }
                
            }
        
            
            Button("Save") {
                habitListVM.saveToFirestore(habitName: habitName, habitDate: habitDate)
                habitName = ""
                presentationMode.wrappedValue.dismiss()
            }
            
        }
    }
}

struct RowView: View {
    
    var habit : Habit
    let vm : HabitListVM
    @State var progressValue: Float = 0.0
    
    
    var body: some View {
        ZStack{
            VStack {
                ProgressBar(habit: habit, progress: self.$progressValue)
                    .frame(width: 150.0, height: 150.0)
                    .onTapGesture {
                        self.updateProgress()
                        vm.toggleItem(habit: habit)
                        
                    }
                    .onAppear{
                        updateProgress()
                    }
                Button(action: {
                    vm.delete(habit: habit)
                }, label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                    
                })
            }
            
        }
    }
    func updateProgress(){
        self.progressValue = habit.progress
    }
}


struct ProgressBar: View {
    
    let habit : Habit
    @Binding var progress: Float
    
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.green)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
            
            Text("Day: " + String(habit.streak))
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.green)
                .padding(.bottom, 50)
            
            Text(habit.name)
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.green)
            
            Text(String(format: "%.0f%%", self.progress * 100))
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.green)
                .padding(.top, 50)
        }
        .onAppear{
            withAnimation(.linear(duration: 0.5)) {
                self.progress = 0.0
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.linear(duration: 0.5)) {
                self.progress = newValue
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        //HabitListView(authVM: AuthViewModel())
        //SignInView(authVM: AuthViewModel())
        RowView(habit: Habit(name: "Running", days: [0]), vm: HabitListVM())
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
