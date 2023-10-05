//
//  MiscellaneousView.swift
//  Debate
//
//  Created by Terrell Davis on 4/18/23.
//

import SwiftUI

struct MiscellaneousView: View {
    var body: some View {
        HStack{
            Timerview(clocktime: 100)
        }
        
    }
}

struct MiscellaneousView_Previews: PreviewProvider {
    static var previews: some View {
        MiscellaneousView()
    }
}

//Timer view just displays the remaining time left on a given debate
struct Timerview: View {
    @State var clocktime: Int
    let timer =  Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(format: "%02i:%02i", clocktime/60,clocktime%60))
            .onReceive(timer) { _ in
                if clocktime > 0 {
                    clocktime -= 1
                }
            }
    }
}


