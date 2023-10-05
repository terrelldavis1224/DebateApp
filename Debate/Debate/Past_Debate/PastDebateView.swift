import Foundation
import SwiftUI
import Firebase

struct DBinfo {
    var user1_vote:Int
    var user2_vote:Int
    var users : [String]
    var name:String
    var topic:String
    var displayName: String
}


class PastDebateInfo: ObservableObject {
    let db = Firestore.firestore()
    let documentRef = Firestore.firestore().collection("previousDebate")
    @Published var debateInfo : [DBinfo] = []

    init() {
        documentRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.debateInfo  = []
                for document in querySnapshot!.documents {
                    let data =  document.data()
                    
                    if let names = data["users"] as? [String], let user2_vote = data["user2_vote"] as? Int,let user1_vote = data["user1_vote"] as? Int,let topic = data["topic"] as? String {
                        
                        var parts = document.documentID.split(separator: ":::", maxSplits: 2, omittingEmptySubsequences: false)
                        print("title")
                        if parts.count > 1 {
                            print(parts)
                            self.debateInfo.append(DBinfo(user1_vote: user1_vote, user2_vote: user2_vote, users: names, name: document.documentID,topic: topic, displayName: String(parts[1])))
                            
                        } else {
                            self.debateInfo.append(DBinfo(user1_vote: user1_vote, user2_vote: user2_vote, users: names, name: document.documentID,topic: topic, displayName: topic ))
                            
                        }
                        
                    }
                }
            }
        }
    }
}
 
struct Debates: View {
    @State var isViewingaDebate = false
    @State var debateNum = 0
    @State var pastDebateInfo:PastDebateInfo = PastDebateInfo()
    var body: some View {
        // amount of past debates
        VStack{
            
            if (isViewingaDebate == false){
                DebatesPreview(pastDebateInfo: $pastDebateInfo, isViewingaDebate: $isViewingaDebate, debateNum: $debateNum)
             
            }else{
                PastDebateView(isViewingaDebate: $isViewingaDebate, debateNum: $debateNum, pastDebateInfo: $pastDebateInfo )
             
              
                
            }
        }
        
    }
    
    //shows a preview of every Previous debate
    struct DebatesPreview:View {
        @Binding var  pastDebateInfo:PastDebateInfo
        @Binding var isViewingaDebate: Bool
        @Binding var debateNum: Int
        var debatetype = ["Education","Politics", "Economy"]
        
        var body: some View{
            VStack{
                Text("Previous Debates")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .bold()
                ScrollView{
                    ForEach(0..<pastDebateInfo.debateInfo.count, id: \.self){ qnum in
                        VStack{ Image(pastDebateInfo.debateInfo[qnum].topic).resizable()
                                .frame(width: 320, height: 150).cornerRadius(8).fixedSize(horizontal: true, vertical: true).overlay(Text(pastDebateInfo.debateInfo[qnum].displayName)
                                .font(.system(size: 24, design: .rounded)),alignment: .topLeading).foregroundColor(.white)
                            BannerView(pastDebateInfo: $pastDebateInfo, debateNum: qnum)
                        }
                                .onTapGesture {
                                isViewingaDebate = true
                                    debateNum = qnum
                            }
                    }
                    
                }
                
            }
            
        }
    }
    
}

// Main View that shows a individual previous debate
//Need to handel error where doc does not exist
struct PastDebateView : View {
    @Binding var isViewingaDebate: Bool
    @Binding var debateNum: Int
    @Binding var  pastDebateInfo:PastDebateInfo

    var body: some View{
        VStack {
            PDebateView(question: pastDebateInfo.debateInfo[debateNum].name, topic: "Education",vote1 : pastDebateInfo.debateInfo[debateNum].user1_vote, vote2 : pastDebateInfo.debateInfo[debateNum].user2_vote).navigationTitle(Text("Testing"))
            Toggle(isOn: $isViewingaDebate){
                Text("Back")
            }.toggleStyle(.button).tint(
                .pink).padding(5)
        }
    }
}

// Simple Image view that goes on top of every previous debate
struct BannerView : View{
    @Binding var  pastDebateInfo:PastDebateInfo
   var debateNum: Int
    var body: some View{
        HStack{
            Text(pastDebateInfo.debateInfo[debateNum].users[0]+":"+pastDebateInfo.debateInfo[debateNum].user1_vote.description)
            Image(systemName: "person.circle.fill").resizable()
                .frame(width: 25.0, height: 25.0).foregroundColor(.red)
            Text("🆚").foregroundColor(.black)
            Image(systemName: "person.circle.fill").resizable()
                .frame(width: 25.0, height: 25.0).foregroundColor(.blue)
            Text(pastDebateInfo.debateInfo[debateNum].users[1]+":"+pastDebateInfo.debateInfo[debateNum].user2_vote.description)
        }
        
    }
}



struct UpvoteView: View {
    @State var state1  = true
    @State var state2 = true
    var body: some View {
        HStack {
            VStack {
                Text("Vote User 1")
                    .font(.title3.weight(.semibold))
                    .padding()
                Button(action: submitUpvote1) {
                    if state1 == true {
                        Image(systemName: "arrow.up.heart.fill")
                    }else{
                        Image(systemName: "arrow.up.heart")
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
                    }else{
                        Image(systemName: "arrow.up.heart")
                    }
                }
            }
        }
    }
    // Also need functionality to update value in firebase
    func submitUpvote1 (){
        state1.toggle()
    }
    func submitUpvote2() {
        state2.toggle()
    }
}
