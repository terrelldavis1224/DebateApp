//
//  ContentView.swift
//  Debate
//
//  Created by Terrell Davis on 3/22/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var User : User
    var body: some View {
        BackgroundView()
    }
}

struct BackgroundView : View{
    @State private var noCurrentViewShowingYet: String = "login"
    
    var body: some View {
        NavigationView{
            ZStack{
                Color(.white).edgesIgnoringSafeArea(.all).opacity(1)
                ControlView(currentViewShowing: $noCurrentViewShowingYet)
            }
        }
    }
}

struct ControlView: View {
    @AppStorage("uid") var userId: String = ""
    @Binding var currentViewShowing: String
    
    
    
    var body: some View {
        
        let _ = print("The currentViewShowing is \(currentViewShowing)")
        
        if userId == "" {
            let _ = print("Entering AuthView")
            
            AuthView(currentViewShowing: $currentViewShowing)
        } else {
            let _ = print("Entering Login or Signup")
            
            // if we came from signup, go to quiz preference
            if currentViewShowing == "signup" {
                let _ = print("Entering Signup")
                QuizView()
            }
            
            // if we came from login, go to homepage
            if currentViewShowing == "login" {
                let _ = print("Entering Login")
                
                HomeView()
            }
        }
    }
}


struct AuthView: View {
    @Binding var currentViewShowing: String
    
    var body: some View {
        let _ = print("Entering AuthView")
        
        if currentViewShowing == "login" {
            let _ = print("Entering LoginView | currentViewShowing: \(currentViewShowing)")
            
            LoginView(currentViewShowing: $currentViewShowing)
        } else {
            let _ = print("Entering SignUpView | currentViewShowing: \(currentViewShowing)")
            
            SignUpView(currentViewShowing: $currentViewShowing).transition(.move(edge: .bottom))
        }
    }
}

struct LoginOrSignUpView : View {
    @State private var wantSignUp: Bool = true
    @State private var userIsLoggedIn: Bool = false
    
    var body: some View {
        VStack {
            if userIsLoggedIn {
                let _ = print("Entering LoginOrSignUpView.userIsLoggedIn")
                HomeView()
            } else {
                VStack {
                    if wantSignUp {
                        let _ = print("Entering LoginOrSignUpView.wantsSignUp")
//                        SignUpView(loginPressed: $wantSignUp)
                    } else {
                        let _ = print("Entering LoginOrSignUpView.!wantsSignUp")
//                        LoginView()
                    }
                }
            }
        }.onAppear {
            Auth.auth().addStateDidChangeListener({ auth, user in
                if user != nil {
                    userIsLoggedIn = true
                }
            })
           
        }
    }
    
}

struct SignUpView : View {
//    @State private var email = ""
//    @State private var password = ""
    @State private var userIsLoggedIn = false
    @Binding var currentViewShowing: String
    @AppStorage("uid") var userId: String = ""
    @EnvironmentObject var User : User
    
    
    var body: some View{
        VStack {
            Text("Sign Up").foregroundColor(.black).bold().font(.largeTitle)
            
            HStack {
                Image(systemName: "mail")
                TextField("Email",text:$User.email).autocapitalization(.none)
            } .padding().overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(.black)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password",text:$User.password)
            } .padding().overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(.black)).padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    
            Button{
                signup()
            } label: {
                Text("Sign Up").font(.system(size: 18)).bold().frame(width: 200, height: 35).background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing))).foregroundColor(.white).padding(EdgeInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0)))
            }
            
            Button{
                currentViewShowing = "login"
            } label: {
                Text("Have an account? Login").underline()
            }.padding(.top).offset(y: 200)
        }.padding()
    }
    
   
    
    func signup() {
        Auth.auth().createUser(withEmail: User.email, password: User.password) {
            result, error in
            if let error = error {
                print(error)
                return
            }
            
            if let result = result {
                userId = result.user.uid
            }
        }
    }
}



struct LoginView : View {
    @EnvironmentObject var User : User
    @Binding var currentViewShowing: String
    @AppStorage("uid") var userId: String = ""
//    @Binding var signupPressed: Bool
    
    var body: some View{
        loginContent
    }
    
    var loginContent: some View {
        VStack {
            Text("Login").bold().font(.largeTitle).foregroundColor(.black)
            
            HStack {
                Image(systemName: "mail")
                TextField("Email",text:$User.email).autocapitalization(.none)
            } .padding().overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(.black)).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password",text:$User.password)
            } .padding().overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(.black)).padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
           
            Button{
                login()
            } label: {
                Text("Sign In").font(.system(size: 18)).bold().frame(width: 200, height: 35).background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing))).foregroundColor(.white).padding(EdgeInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0)))
            }
            
            Button{
                // Go to sign up page
                currentViewShowing = "signup"
            } label: {
                Text("Don't have an account? Sign up now!").underline()
            }.padding(.top).offset(y: 200)
        }.padding()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: User.email, password: User.password) {
            result, error in
            if let error = error {
                print(error)
            }
            
            if let result = result {
                print(result.user.uid)
                withAnimation {
                    userId = result.user.uid
                }
            }
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(User())
    }
}
