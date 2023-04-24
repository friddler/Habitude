//
//  SummaryHabitView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-21.
//

import SwiftUI

struct SummaryHabitView: View {
    
    @ObservedObject var habitListVM = HabitListVM()
    //let habit : Habit
    
    
    var body: some View {
        List(habitListVM.habits) { habit in
            VStack (alignment: .leading, spacing: 8){
                Text(habit.name)
                    .font(.headline)
                    .background(Color(.systemGray6))
                
                VStack (alignment: .leading){
                    Text("Monday")
                    Text("Tuesday")
                    Text("Wednesday")
                    Text("Thursday")
                    Text("Friday")
                    Text("Saturday")
                    Text("Sunday")
                    
                }
                
                HStack {
                    ForEach(0..<7) { index in
                        let isDone = habit.days.contains(index)
                        Text("\(isDone ? "✅" : "❌")")
                    }
                }
            }
        }
    }
}


struct SummaryHabitView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryHabitView()
    }
}

