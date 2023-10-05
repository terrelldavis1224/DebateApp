//
//  MessageView.swift
//  Debate
//
//  Created by Aarav Naveen on 4/22/23.
//

import SwiftUI
import Firebase

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var sent: Bool
    var time: Date
    var username: String
}

struct MessageBubble: View {
    
    var message: Message
    @State private var timeOn = false
    let displayName: String? = Auth.auth().currentUser?.displayName
    
    var body: some View {
        VStack (alignment: (displayName == message.username) ? .trailing : .leading) {
            if !message.sent && displayName != message.username {
                Text(message.username)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            
            HStack {
                Text(message.text)
                    .padding()
                    .background((displayName == message.username) ? .yellow : .cyan)
                    .foregroundColor((displayName == message.username) ? .black : .white)
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: (displayName == message.username) ? .trailing : .leading)
            .onTapGesture {
                timeOn.toggle()
            }
            
            if(timeOn) {
                Text(message.time.formatted(.dateTime.hour().minute().second()))
                    .font(.footnote)
                    .padding((displayName == message.username) ? .trailing : .leading, 20)
            }
        }
        .frame(maxWidth: 100000000, alignment: (displayName == message.username) ? .trailing : .leading)
        .padding()
    }
}
