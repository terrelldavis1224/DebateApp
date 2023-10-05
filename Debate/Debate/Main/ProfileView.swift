//
//  ProfileView.swift
//  Debate
//
//  Created by Terrell Davis on 4/8/23.
//
import SwiftUI
import Firebase

struct ProfileView: View{
    @Binding var currentViewShowing: String
    @AppStorage("uid") var userId: String = ""
    @State var userName = Auth.auth().currentUser?.displayName
    @EnvironmentObject var User : User
    
    var body: some View{
        VStack{
            ProfileSymbolView()
         
            
            Text("Email: "+userName!)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 20))
            
            Divider().frame(minHeight: 2).overlay(Color.black)
            
            Text("uid: \(userId)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 20))
            Divider().frame(minHeight: 2).overlay(Color.black)
            
            Text("Number of Debates:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 20))
            Divider().frame(minHeight: 2).overlay(Color.black)
            
            
            Button("Redo Preference Quiz"){
                User.getUserInfo()
                currentViewShowing = "signup"
            }.tint(.pink)
            
            LogoutView()
            Spacer()
        }
    }
    
    
   
}

struct LogoutView: View {
    @AppStorage("uid") var userId: String = ""
    @EnvironmentObject var User : User

    var body : some View {
        Divider().frame(minHeight: 2).overlay(Color.black)
        Button("Logout") {
            print("We will be signing out")
            signout()
            
        }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(.pink)

    }
    func signout() {
        try! Auth.auth().signOut()
        withAnimation {
            userId = ""
                User.Prefselection = [false,false,false,false,false,false]
                User.profilePictureOption = 0
        }
    }
}

struct ProfileSymbolView: View {
    @EnvironmentObject var User : User
    var body: some View {
        
        Image(systemName: "\(User.get_profilepicture()).circle.fill").resizable()
                    .frame(width: 100.0, height: 100.0).foregroundColor(.pink)
        Button("Change Picture") {
            User.profilePictureOption += 1
            User.setUserInfo()
        }.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(.pink).padding()
        Divider().frame(minHeight: 2).overlay(Color.black)

      
    }
}



