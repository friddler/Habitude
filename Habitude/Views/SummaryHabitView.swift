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
    

    var body: some View {
        VStack(spacing: 30) {
            VStack {
                ProgressViewComplete(habit: habit, progress: .constant(1.0))
                    .frame(width: 150.0, height: 150.0)
                    .padding(.horizontal, 10)
                    .padding(.top, 30)
                Spacer()
                
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
                .rotationEffect(Angle(degrees: 270.0)) //?? check out
                .shadow(radius: 5)
            
            Text(habit.name)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.green)
             
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

struct SummaryHabitView_Previews: PreviewProvider {
    static var previews: some View {
        //SummaryHabitView()
        //CompletedHabitView(habitlistVM: HabitListVM(), habit: Habit(name: "Running", days: [0]))
        let mockHabits = [
                    Habit(name: "Running", streak: 5, isTapped: true, progress: 0.5, done: false, days: [1, 3, 5], lastToggled: Date(), habitStarted: Date()),
                    Habit(name: "Meditation", streak: 10, isTapped: false, progress: 0.8, done: true, days: [1, 2, 3, 4, 5, 6, 7], lastToggled: Date(), habitStarted: Date())
                ]
                
                let habitListVM = HabitListVM()
                habitListVM.completedHabits = mockHabits
                
                return SummaryHabitView(habitListVM: habitListVM)
    }
}

