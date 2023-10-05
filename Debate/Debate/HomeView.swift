//
//  HomeView.swift
//  DebateTest
//
//  Created by Eric Gulich on 3/30/23.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @AppStorage("uid") var userId: String = ""
    @State var signOutPressed: Bool = false
    
    var body: some View {
        VStack {
            Text("heyo")
            if signOutPressed {
//                SignUpView(loginPressed: $signOutPressed)
            } else {
                Button("Sign out") {
                    print("This is the userId: \(userId)")
                    print("We will be signing out")
                    signout()
                    userId = ""
                }
            }
        }
    }
    func signout() {
        try! Auth.auth().signOut()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
