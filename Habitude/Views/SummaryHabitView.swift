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
        List(habitListVM.habits) { habit in
            VStack (alignment: .leading, spacing: 8){
                Text(habit.name)
                    .font(.headline)
                    .background(Color(.systemGray6))
                
                
            }
        }
    }
}


struct SummaryHabitView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryHabitView()
    }
}

