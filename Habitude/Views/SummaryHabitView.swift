//
//  SummaryHabitView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-21.
//

import SwiftUI

struct SummaryHabitView: View {
    
    @ObservedObject var habitListVM = HabitListVM()
    
    var body: some View {
        VStack{
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(habitListVM.completedHabits) { habit in
                        CompletedHabitView(habitlistVM: habitListVM, habit: habit)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 200)
            Spacer()
            
            Text("Summary").font(.title)
            List {
               
            }

        }
        .onAppear {
            habitListVM.listenToCompletedHabitsFirestore()
            print(habitListVM.completedHabits.count)
        }

    }
    
}

struct CompletedHabitView: View {
    
    var habitlistVM : HabitListVM
    let habit : Habit
    @State var isFlipped = false
    
    var body: some View {
        ZStack {
            VStack {
                ProgressViewComplete(habit: habit, progress: .constant(1.0))
                    .frame(width: 150.0, height: 150.0)
                    .padding(.horizontal, 10)
                    .padding(.top, 30)
                    .onTapGesture {
                        withAnimation {
                            self.isFlipped.toggle()
                        }
                    }
                    .opacity(isFlipped ? 0 : 1)
                Spacer()
            }
            
            VStack {
                Text("Start: \(String(habit.formattedStartDate))")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .frame(width: 100, height: 40)
                Text("End: \(String(habit.formattedEndDate))")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .frame(width: 100, height: 40)
        
            }
            .frame(width: 150, height: 150)
            .scaleEffect(x: -1) // without this the text gets mirrored
            .background(Circle().foregroundColor(.green).opacity(0.2))
            .overlay(Circle().stroke(lineWidth: 20.0).foregroundColor(.green).shadow(radius: 5))
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1 : 0)
            .onTapGesture {
                withAnimation {
                    self.isFlipped.toggle()
                }
            }
        }
    }
}

struct ProgressViewComplete: View {
    
    let habit : Habit
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.green)
                .shadow(radius: 5)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .shadow(radius: 5)
            
            Text(habit.name)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.green)
            
        }
    }
}

struct SummaryHabitView_Previews: PreviewProvider {
    static var previews: some View {
        //SummaryHabitView()
        //CompletedHabitView(habitlistVM: HabitListVM(), habit: Habit(name: "Running"))
        let mockHabits = [
                    Habit(name: "Running", streak: 5, isTapped: true, progress: 0.5, done: false, lastToggled: Date(), habitStarted: Date()),
                    Habit(name: "Meditation", streak: 10, isTapped: false, progress: 0.8, done: true, lastToggled: Date(), habitStarted: Date())
                ]
                
                let habitListVM = HabitListVM()
                habitListVM.completedHabits = mockHabits
                
                return SummaryHabitView(habitListVM: habitListVM)
    }
}

