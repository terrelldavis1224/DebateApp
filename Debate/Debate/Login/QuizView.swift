//
//  QuizView.swift
//  DebateTest
//
//  Created by Eric Gulich on 3/30/23.
//


import SwiftUI
import Firebase


struct QuizView: View {
   @Binding var currentViewShowing: String
   @State var signOutPressed: Bool = false
   @AppStorage("uid") var userId: String = ""
   @EnvironmentObject var User : User
   var body: some View {
       NavigationView {
           VStack {
               Divider().frame(minHeight: 2).overlay(Color.black)
               //Text("Hello! This is your uid: \(userId)")
               QuestionToggle(question: "Q1.Do You be believe in magic.", questionNum:0)
               QuestionToggle(question: "Q2.Is a hotdog a sandwich.", questionNum:1)
               QuestionToggle(question: "Q3.Is 0 a natural number.", questionNum:2)
               QuestionToggle(question: "Q4.Toilet paper over.", questionNum:3)
               QuestionToggle(question: "Q5.Team edward.", questionNum:4)
               QuestionToggle(question: "Q6.Do you believe in an afterlife?", questionNum:5)
               Divider().frame(minHeight: 2).overlay(Color.black)

               Button("Done") {
                   print("We will be signing out")
                   User.setUserInfo()
                   currentViewShowing = "quiz"
                   //Need to link with HomeView()
               }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(.pink)
              
           }
           .navigationTitle("Preference Quiz").navigationBarTitleDisplayMode(.inline)
          
       }
   }
  
   struct QuestionToggle : View {
       @EnvironmentObject var User : User
      var question: String
      var questionNum: Int
       var body : some View {
           Text(question).font(.system(size: 13)).bold().frame(width: 200, height: 35).background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing))).foregroundColor(.white).padding(EdgeInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0)))
           Toggle(isOn:$User.Prefselection[questionNum]){
               if User.Prefselection[questionNum] {
                   Text("Yes")
               }else {
                   Text("No")
               }
           }.toggleStyle(.button).tint(
               .pink).padding(5)


       }
   }
  
   func signout() {
       try! Auth.auth().signOut()
       withAnimation {
           userId = ""
       }
   }
        


}
