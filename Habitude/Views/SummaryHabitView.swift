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
        ZStack {
            LottieView(loopMode: .loop, animationName: "green")
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            
            VStack{
                
                Text("Completed Habits").font(.title2)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 55)
                   
                
                ScrollView(.horizontal) {
                    HStack(spacing: 30) {
                        ForEach(habitListVM.completedHabits) { habit in
                            CompletedHabitView(habitlistVM: habitListVM, habit: habit)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 200)
                
                VStack{
                    CardView(header: "Today", habitCount: habitsCompleted(for: .day))
                    CardView(header: "This Week", habitCount: habitsCompleted(for: .weekOfYear))
                    CardView(header: "This Month", habitCount: habitsCompleted(for: .month))
                    CardView(header: "This Year", habitCount: habitsCompleted(for: .year))
                }
                .padding(.top, 30)
                
                Spacer()
    
            }
        }
        .onAppear {
            habitListVM.listenToCompletedHabitsFirestore()
            print(habitListVM.completedHabits.count)
        }
    }
    func habitsCompleted(for component: Calendar.Component) -> Int {
        habitListVM.completedHabits.filter { $0.lastToggled?.isWithinSame(component: component, as: Date()) == true }.count
    }
    
}

struct CardView: View {
    var header: String
    var habitCount: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(header)
                .font(.headline)
            Text("\(habitCount)")
        }
        .padding(.bottom, 10)
        .padding(.top, 10)
        .frame(maxWidth: 160)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .frame(width: 100, height: 40)
            
                Text("End: \(String(habit.formattedEndDate))")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .frame(width: 100, height: 40)
                    
                
            }
            .frame(width: 150, height: 150)
            .scaleEffect(x: -1) // without this the text gets mirrored
            .background(Circle().foregroundColor(.green).opacity(0.1))
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
        SummaryHabitView()
        //CompletedHabitView(habitlistVM: HabitListVM(), habit: Habit(name: "Running"))
       
    }
}

