//
//  QuizView.swift
//  DebateTest
//
//  Created by Eric Gulich on 3/30/23.
//

import SwiftUI
import Firebase

struct QuizView: View {
    @State var signOutPressed: Bool = false
    @AppStorage("uid") var userId: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello! This is your uid: \(userId)")
                Button("Sign out") {
                    print("We will be signing out")
                    signout()
                    self.signOutPressed = true
                }
                
            }
            .navigationTitle("Preference Quiz")
            
        }
    }
    
    func signout() {
        try! Auth.auth().signOut()
        withAnimation {
            userId = ""
        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView().environmentObject(User())
    }
}
