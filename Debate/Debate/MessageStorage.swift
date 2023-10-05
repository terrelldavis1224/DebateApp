//
//  MessageStorage.swift
//  Debate
//
//  Created by Aarav Naveen on 4/22/23.
//

import SwiftUI
import Firebase
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessageStorage: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastMsgID = ""
    let db = Firestore.firestore()
    let question: String
    let topic: String
    let documentRef : DocumentReference
    
    init(question: String, topic: String) {
        self.question = question
        self.topic = topic
        documentRef = db.collection("Topics").document(topic).collection("DebateQuestions").document(question)
        getMessages()
    }
    
    func getMessages() {
        documentRef.collection("Replies").addSnapshotListener { qs, error in
            guard let docs = qs?.documents else {
                print("Error")
                return
            }
            
            self.messages = docs.compactMap { document -> Message? in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error")
                    return nil
                }
            }
            
            self.messages.sort {
                $1.time > $0.time
            }
            
            if let id = self.messages.last?.id {
                self.lastMsgID = id
            }
            
        }
    }
    
    func sendMessages(_ msg : String) {
        
        // getting the display name (username) from Firebase Auth
        if let displayName = Auth.auth().currentUser?.displayName {
            do {
                let temp = Message(id: "\(UUID())", text: msg, sent: false, time: Date(), username: displayName)
                
                
                // add debate questions
                try documentRef.collection("Replies").document().setData(from: temp)
                
                // add number of users in that reply
                documentRef.setData([
                    "users": FieldValue.arrayUnion([displayName]),
                    "user1_vote": 0,
                    "user2_vote": 0,
                    "uniqueID": Int.random(in: 0...214748364).description+":::"+question
//                    "time_is_up": false, // add time_is_up variable
//                    "start_time": Timestamp(date: Date())
                ], merge: true) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
                // get number of users that have written in that question and if == 2
                documentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let fieldValue = document.get("users") as? [String], fieldValue.count == 2 {
                            if document.get("start_time") is Timestamp {
                                print("Already a start time")
                            } else {
                                self.documentRef.setData([
                                    "start_time": Timestamp(date: Date()),
                                ], merge: true)
                            }
                        } else {
                            print("there aren't two people yet")
                        }
                    } else {
                        print("Document does not exist.")
                    }
                }
                
            } catch {
                print("Error")
            }
        } else { // if not display name found
            print("Display name not set")
        }
        
        
    }
    
    
}






class PastMessageStorage: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastMsgID = ""
    let db = Firestore.firestore()
    let question: String
    let topic: String
    let documentRef : DocumentReference
    
    init(question: String, topic: String) {
        self.question = question
        self.topic = topic
        documentRef = db.collection("previousDebate").document(question)
        getMessages()
    }
    
    func getMessages() {
        documentRef.collection("Replies").addSnapshotListener { qs, error in
            guard let docs = qs?.documents else {
                print("Error")
                return
            }
            
            self.messages = docs.compactMap { document -> Message? in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error")
                    return nil
                }
            }
            
            self.messages.sort {
                $1.time > $0.time
            }
            
            if let id = self.messages.last?.id {
                self.lastMsgID = id
            }
            
        }
    }
    
    func sendMessages(_ msg : String) {
        
        // getting the display name (username) from Firebase Auth
        if let displayName = Auth.auth().currentUser?.displayName {
            do {
                let temp = Message(id: "\(UUID())", text: msg, sent: false, time: Date(), username: displayName)
                
                
                // add debate questions
                try documentRef.collection("Replies").document().setData(from: temp)
                
                // add number of users in that reply
                documentRef.setData([
                    "users": FieldValue.arrayUnion([displayName]),
                    "user1_vote": 0,
                    "user2_vote": 0
//                    "time_is_up": false, // add time_is_up variable
//                    "start_time": Timestamp(date: Date())
                ], merge: true) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
                // get number of users that have written in that question and if == 2
                documentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let fieldValue = document.get("users") as? [String], fieldValue.count == 2 {
                            if document.get("start_time") is Timestamp {
                                print("Already a start time")
                            } else {
                                self.documentRef.setData([
                                    "start_time": Timestamp(date: Date()),
                                ], merge: true)
                            }
                        } else {
                            print("there aren't two people yet")
                        }
                    } else {
                        print("Document does not exist.")
                    }
                }
                
            } catch {
                print("Error")
            }
        } else { // if not display name found
            print("Display name not set")
        }
        
        
    }
    
    
}


