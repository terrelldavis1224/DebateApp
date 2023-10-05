//
//  DebateView.swift
//  Debate_App
//
//  Created by Aarav Naveen on 4/5/23.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct MessageField: View {
    @EnvironmentObject var messageStorage: MessageStorage
    @State private var message = ""
    let topic: String
    let question: String
    @State private var showField: Bool? = nil
    let displayName: String? = Auth.auth().currentUser?.displayName
    @State var heart1 = "arrow.up.heart"
    @State var heart2 = "arrow.up.heart"
    @State var state1  = false
    @State var state2 = false
    @State var vote1: Int = 0
    @State var vote2: Int = 0
    @State var upvote_list1: [String] = []
    @State var upvote_list2: [String] = []
    
    
    var body: some View {
        VStack {
            messageFieldView
        }
        .onAppear {
            fetchDocument()
            getVote()
        }
    }
    
    // Removes the Debate from Main Debate and creates a new Debate with different name
//    func copyDoc(){
//        // Random name but not unique so need to be fixed
//        let newDocName = Int.random(in: 0...214748364).description+":::"+question
//        let db = Firestore.firestore()
//        let previousDebateDoc = db.collection("previousDebate")
//        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
//        let newDoc = db.collection("Topics").document(topic).collection("DebateQuestions").document(newDocName)
//
//        documentRef.getDocument{ (document, error) in
//            if let document = document, document.exists {
//                //copies non reply data
//                let data = document.data()
//                newDoc.setData(data!)
//                documentRef.collection("Replies").getDocuments() { (querySnapshot, err) in
//                    if let err = err {
//                        print ("can't copy Debate")
//                    } else {
//                        // copies reply data
//                        for document in querySnapshot!.documents {
//                            newDoc.collection("Replies").document().setData(document.data())
//
//                        }
//                        // stores the names of copies of the dabte to use in the PastDebate view
//                        previousDebateDoc.document(newDocName).setData(["name":newDocName,"topic": topic])
//                        // remove the debate for the debate view
//                        documentRef.delete()
//                    }
//                }
//            }
//
//
//        }
//
//    }
    
    func copyDoc(){
        print("Entering copyDoc")
        let db = Firestore.firestore()
        let previousDebateDoc = db.collection("previousDebate")
        let sourceDoc = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
     
        
        sourceDoc.getDocument { (document, error) in
            if let document = document, document.exists {
               let data = document.data()
               let userv1 =  data?["user1_vote"] as? Int
               let userv2 = data?["user2_vote"]  as? Int
               let stime = data?["start_time"]  as? Timestamp
               let userlist = data?["users"]  as? [String]
               let uniqueID = data?["uniqueID"]  as? String
                previousDebateDoc.document(uniqueID!).setData(["start_time": stime,"user1_vote": userv1 ,"user2_vote": userv2,"users": userlist , "topic": topic]) // Copy data to new location
            
                sourceDoc.collection("Replies").getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print ("Can't copy Debate:", err)
                    } else {
                        // Copies reply data
                        for document in querySnapshot!.documents {
                            previousDebateDoc.document(uniqueID!).collection("Replies").document().setData(document.data())
                        }
                        
                        for document in querySnapshot!.documents {
                            sourceDoc.collection("Replies").document(document.documentID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                }
                            }
                        }
                        
                        // Delete the original document and its Replies subcollection
                        sourceDoc.delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func fetchDocument() {
        guard let currentUserDisplayName = Auth.auth().currentUser?.displayName else {
            showField = false
            return
        }
        
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let fieldValue = document.get("users") as? [String], fieldValue.count < 2 {
                    // if there are less than two people, then yes there is not going to be an issue. Anyone can type
                    showField = true
                } else {
                    if let fieldValue = document.get("users") as? [String], fieldValue.contains(currentUserDisplayName) {
                        // if 2 people have already typed, but the current user is one of the two people,
                        
                        if let startTime = document.get("start_time") as? Timestamp {
                            // Get current time
                            let currentTime = Timestamp(date: Date())
                            
                            // Calculate the time difference in seconds
                            let timeDifference = currentTime.seconds - startTime.seconds
                            
                            // Check if the 5-minute time limit has not passed
                            if timeDifference < 30 { // 300 seconds = 5 minutes
                                showField = true
                            } else {
                                showField = false
                                copyDoc()
                            }
                        } else {
                            print("Start time not found.")
                            showField = false
                        }
                    } else {
                        showField = false
                    }
                }
                
            } else {
                showField = true
            }
        }
    }
    
    func getVote() {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
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
    
    func getVoteList1() {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                upvote_list1 = dataDescription?["upvote_list1"] as! [String]
            } else {
                print("Document does not exist")
            }
        }
    }
    func getVoteList2() {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                upvote_list2 = dataDescription?["upvote_list2"] as! [String]
            } else {
                print("Document does not exist")
            }
        }
    }
    //
    func updateVote1(_ val: Int) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "user1_vote": val
        ])
    }
    
    func updateVote2(_ val: Int) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "user2_vote": val
        ])
    }
    //Removes username from a list of names that have already voted
    func updateVoteListRem1(_ val: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "upvote_list1":FieldValue.arrayRemove([val])
        ])
    }
    //adds username from a list of names that have already voted
    func updateVoteListAdd1(_ val: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "upvote_list1":FieldValue.arrayUnion([val])
        ])
    }
    //Removes username from a list of names that have already voted
    func updateVoteListRem2(_ val: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "upvote_list2":FieldValue.arrayRemove([val])
        ])
    }
    
    //adds username from a list of names that have already voted
    func updateVoteListAdd2(_ val: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.updateData([
            "upvote_list2":FieldValue.arrayUnion([val])
        ])
    }
    
    
    func submitUpvote1(){
        state1.toggle()
    }
    func submitUpvote2() {
        state2.toggle()
    }
    
    @ViewBuilder
    private var messageFieldView: some View {
        if let show = showField, show {
            HStack {
                TextBox(text: Text("Enter your message here"), msg: $message)
                    .frame(height: 52)
                    .disableAutocorrection(true)
                
                Button {
                    messageStorage.sendMessages(message)
                    message = ""
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(50)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 1)
            .background(Color.orange)
            .cornerRadius(30)
            .padding()
        }
        else {
            HStack { //"arrow.up.heart.fill"
                VStack {
                    Text("Vote User 1: \(vote1)")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Image(systemName: heart1)
                        .onTapGesture {
                            state1.toggle()
                            if state1 {
                                heart1 = "arrow.up.heart.fill"
                                vote1 += 1
                                updateVote1(vote1)
                            }
                            else {
                                heart1 = "arrow.up.heart"
                                vote1 -= 1
                                updateVote1(vote1)
                            }
                        }
                }
                Spacer()
                VStack {
                    Text("Vote User 2: \(vote2)")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Image(systemName: heart2)
                        .onTapGesture {
                            state2.toggle()
                            if state2 {
                                heart2 = "arrow.up.heart.fill"
                                vote2 += 1
                                updateVote2(vote2)
                            }
                            else {
                                heart2 = "arrow.up.heart"
                                vote2 -= 1
                                updateVote1(vote2)
                            }
                        }
                }
            }
        }
        
    }
    
}

struct TextBox: View {
    var text: Text
    @Binding var msg: String
    var change: (Bool) -> () = { _ in }
    var commit: () -> () = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if msg.isEmpty {
                text
            }
            TextField("", text: $msg, onEditingChanged: change, onCommit: commit)
        }
    }
}

struct DebateView: View {
    
    @State private var timeRemaining: Int = 300
    @State private var hasStartTime: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject var messageStorage : MessageStorage
    let question: String
    let topic: String
    let parts: Array<Substring>
    let title: String
    var t :Int64{ getTime()
        
    }
    init (question: String, topic: String) {
        self.question = question
        self.topic = topic
        _messageStorage = StateObject(wrappedValue: MessageStorage(question: question, topic: topic))
        self.parts = question.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        print("title")
        if parts.count > 1 {
            print(parts)
            self.title = String(parts[2])
        } else {
            self.title = question
        }
        print("Let's see what happens now")
        print(self.question)
        print(self.topic)
    }
    
    func getFirebaseTimestamp() {
            let db = Firestore.firestore()

            // Access the Firestore collection for the current topic and debate question.
            db.collection("Topics").document(self.topic).collection("DebateQuestions").document(self.question)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: (error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }

                    if let timestamp = data["start_time"] as? Timestamp {
                        let dateValue = timestamp.dateValue()
                        let now = Date()
                        let diff = Calendar.current.dateComponents([.second], from: dateValue, to: now)

                        if let diffSeconds = diff.second {
                            self.timeRemaining = 300 - diffSeconds
                            self.hasStartTime = self.timeRemaining > 0
                        }
                    }
                }
        }
    
    
    var body: some View {
        VStack {
            VStack {
                Text("Debate Topic: " + title)
                    .padding()
                    .background(.teal)
                    .cornerRadius(20)
                Spacer()
                HStack {
                    
                    if self.hasStartTime {
                        Text("Time left: ")
                            .padding()
                            .bold()
                        
                        // This code defines a Text view that displays the time remaining for a debate question in the format "MM:SS".
                        Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                    }
                    
                    
                }.onAppear(perform: getFirebaseTimestamp)
                    .onReceive(timer) { _ in
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        } else {
                            self.hasStartTime = false
                        }
                    }
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
            
            MessageField(topic: topic, question: question)
                .environmentObject(messageStorage)
        }
        
    }
    
    func getTime () -> Int64 {
        var time:Int64 = -1
        let db = Firestore.firestore()
        let documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let fieldValue = document.get("users") as? [String], fieldValue.count == 2 {
                    if let startTime = document.get("start_time") as? Timestamp {
                        let currentTime = Timestamp(date: Date())
                        
                        time = currentTime.seconds - startTime.seconds
                    } else {
                        
                    }
                } else {
                    
                }
                
            } else {
                
            }
        }
        return time
    }
    
}




struct PDebateView: View {
    
    @State private var timeRemaining: Int = 300
    @State private var hasStartTime: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject var messageStorage : PastMessageStorage
    let question: String
    let topic: String
    let parts: Array<Substring>
    let title: String
    @State var heart1 = "arrow.up.heart"
    @State var heart2 = "arrow.up.heart"
    @State var state1  = false
    @State var state2 = false
    @State var vote1: Int = 0
    @State var vote2: Int = 0
    @State var upvote_list1: [String] = []
    @State var upvote_list2: [String] = []
    init (question: String, topic: String, vote1: Int , vote2:Int) {
        self.question = question
        self.topic = topic
        self.vote1 = vote1
        self.vote2 = vote2
        _messageStorage = StateObject(wrappedValue: PastMessageStorage(question: question, topic: topic))
        self.parts = question.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        print("title")
        if parts.count > 1 {
            print(parts)
            self.title = String(parts[2])
        } else {
            self.title = question
        }
        print("Let's see what happens now")
        print(self.question)
        print(self.topic)
        
    }
    var body: some View {
        VStack {
            VStack {
                Text("Debate Topic: " + title)
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
            
            HStack { //"arrow.up.heart.fill"
                VStack {
                    Text("Vote User 1: \(vote1)")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Image(systemName: heart1)
                        .onTapGesture {
                            state1.toggle()
                            if state1 {
                                heart1 = "arrow.up.heart.fill"
                                vote1 += 1
                                //updateVote1(vote1)
                            }
                            else {
                                heart1 = "arrow.up.heart"
                                vote1 -= 1
                                //  updateVote1(vote1)
                            }
                        }
                }
                Spacer()
                VStack {
                    Text("Vote User 2: \(vote2)")
                        .font(.title3.weight(.semibold))
                        .padding()
                    Image(systemName: heart2)
                        .onTapGesture {
                            state2.toggle()
                            if state2 {
                                heart2 = "arrow.up.heart.fill"
                                vote2 += 1
                                //        updateVote2(vote2)
                            }
                            else {
                                heart2 = "arrow.up.heart"
                                vote2 -= 1
                                //      updateVote1(vote2)
                            }
                            
                        }
                }
            }
            
        }
        
    }
    
}
