//
//  VoteView.swift
//  Debate
//
//  Created by Phuoc Nguyen on 4/30/23.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct VoteView: View {
    
    
    @StateObject var messageStorage : MessageStorage
    let question: String
    let topic: String
    let db = Firestore.firestore()
    let documentRef : DocumentReference
    @State var vote1: Int = 0
    @State var vote2: Int = 0
    @State var state1  = false
    @State var state2 = false
    
    init (question: String, topic: String) {
        self.question = question
        self.topic = topic
        _messageStorage = StateObject(wrappedValue: MessageStorage(question: question, topic: topic))
        documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        print("Let's see what happens now")
        print(self.question)
        print(self.topic)
    }
    
    func submitUpvote1 (){
        state1.toggle()
    }
    func submitUpvote2() {
        state2.toggle()
    }
    
    func getVote() {
        documentRef.getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                vote1 = dataDescription?["user1_vote"] as! Int
                vote2 = dataDescription?["user2_vote"] as! Int
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateVote1(_ val: Int) {
        documentRef.updateData([
            "user1_vote": val
        ])
    }
    
    func updateVote2(_ val: Int) {
        documentRef.updateData([
            "user2_vote": val
        ])
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Debate Topic: " + question)
                    .padding()
                    .background(.teal)
                    .cornerRadius(20)
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messageStorage.messages, id: \.id){ msg in MessageBubble(message: msg)
                            
                        }
                    }
                    .padding(.top, 20)
                    .background(Color.white)
                    .onChange(of: messageStorage.lastMsgID) { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(.orange)
            HStack {
                VStack {
                    Text("Vote User 1")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Button(action: submitUpvote1) {
                        if state1 == true {
                            Image(systemName: "arrow.up.heart.fill")
                                /*.onTapGesture {
                                    getVote()
                                    vote1 += 1
                                    updateVote1(vote1)
                                }*/
                        }else{
                            Image(systemName: "arrow.up.heart")
                                /*.onTapGesture {
                                    getVote()
                                    vote1 -= 1
                                    updateVote1(vote1)
                                }*/
                        }
                    }
                }
                Spacer()
                VStack {
                    Text("Vote User 2")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Button(action: submitUpvote2) {
                        if state2 == true {
                            Image(systemName: "arrow.up.heart.fill")
                                /*.onTapGesture {
                                    getVote()
                                    vote2 += 1
                                    updateVote2(vote2)
                                }*/
                        }else{
                            Image(systemName: "arrow.up.heart")
                                /*.onTapGesture {
                                    getVote()
                                    vote2 -= 1
                                    updateVote2(vote2)
                                }*/
                        }
                    }
                }
            }
        }
    }
}


