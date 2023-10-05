//
//  Model.swift
//  Debate
//
//  Created by Terrell Davis on 3/23/23.
//

import Foundation
import Firebase


struct Topic: Hashable, Equatable, Codable {
    var title: String
    var questions: [String]
}

class TopicList: ObservableObject {
    @Published var list: [Topic] {
        didSet {
            saveTopic()
        }
    }
    @Published var selected: Bool
    let topicKey: String = "topic_list"
    
    init() {
        list = [Topic(title: "Education", questions: ["Should the government subsidize college education?", "Should prayer be allowed in public schools?"]), Topic(title: "Politics & Government", questions: ["Does the government have a valid role in reproductive rights?", "What are the pros and cons of voting for a third party?"]), Topic(title: "Science & Technology", questions: ["Should we restrict research and development into artificial intelligence?", "What, if any, limits should there be on genetics research?"]), Topic(title: "Health", questions: ["Is it valid to allow alcohol sales in light of its detrimental impact on the nation's mental and physical health?", "Childhood obesity is a growing epidemic. How should parents, schools, and government address this public health problem?"]), Topic(title: "Economy", questions: ["Should the nation institute policies that address income inequality?", "Should crypto currency, such as Bitcoin, be considered an asset and used as legal tender in business transactions?"]), Topic(title: "Pop Culture", questions: ["Team Edward or Team Jacob", "What's your favorite color?"]), Topic(title: "Wacky Questions", questions: ["Why is eric the best?", "What is eric's favorite color?"])]
        selected = false
    }
    
    func addQuestion(topic: Topic, question: String) {
        for i in 0..<list.count {
            if list[i].title == topic.title {
                list[i].questions.append(question)
                break
            }
        }
    }
    
  
    func getTopic() {
        guard
            let data = UserDefaults.standard.data(forKey: topicKey),
            let savedTopic = try? JSONDecoder().decode([Topic].self, from: data)
        else { return }
        
        self.list = savedTopic
    }
    
    func saveTopic() {
        if let encodedData = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(encodedData, forKey: topicKey)
        }
    }
}



class User :ObservableObject{
    @Published var id:Int
    @Published var email : String
    @Published var password : String
    @Published var username : String
    @Published var Prefselection: [Bool]
    @Published var profilePictureOption : Int
    
    init() {
        self.id = 0
        self.email = ""
        self.password = ""
        self.username = ""
        self.Prefselection = [false,false,false,false,false,false]
        self.profilePictureOption = 0
    }
    
    
    func get_profilepicture() ->String{
        if (profilePictureOption > 7 ){
            profilePictureOption = 0
        }
        if(profilePictureOption == 0){
            return "moon"
        }else if (profilePictureOption == 2){
            return "flame"
        }else if (profilePictureOption == 3){
            return "heart"
        }else if (profilePictureOption == 4){
            return "football"
        }else if(profilePictureOption == 5){
            return "theatermasks"
        }else if (profilePictureOption == 6){
            return "trophy"
        }else{
            return "person"
        }
    }
    
    // sets users info for new user or on start up get user info
    func getUserInfo(){
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document((Auth.auth().currentUser?.displayName)!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                var currentUserPref = dataDescription?["ans"] as! [Bool]
                var PfP = dataDescription?["PfP"] as! Int
                self.Prefselection = currentUserPref
                self.profilePictureOption = PfP
                
            } else {
                db.collection("Users").document((Auth.auth().currentUser?.displayName)!).setData(["ans" : [false,false,false,false,false,false],"PfP" : 0])
                self.Prefselection = [false,false,false,false,false,false]
            }
        }
        
    }
    
    
    //set user pref quiz when done
    func setUserInfo(){
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document((Auth.auth().currentUser?.displayName)!)
      //  docRef.getDocument { (document, error) in
         //   if let document = document, document.exists {
                
           // } else {
                db.collection("Users").document((Auth.auth().currentUser?.displayName)!).setData(["ans" : self.Prefselection,"PfP":self.profilePictureOption])

           // }
        //}
        
    }
    
}




