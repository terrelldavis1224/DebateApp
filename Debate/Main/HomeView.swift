//
//  HomeView.swift
//  DebateTest
//
//  Created by Eric Gulich on 3/30/23.
//

import SwiftUI
import Firebase
import CoreMotion

struct HomeView: View {
    @Binding var currentViewShowing: String
    @AppStorage("uid") var userId: String = ""
    @State var signOutPressed: Bool = false
    @State private var selectedTab = 0
    @State private var motionManager = CMMotionManager()
    
    @ObservedObject var topic: TopicList = TopicList()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Home()
                .environmentObject(topic)
                .tabItem {
                    Label("Home", systemImage: "house").foregroundColor(.black)
                }
                .tag(0)
            Debates()
                .environmentObject(topic)
                .tabItem {
                    Label("Debates", systemImage: "checkmark.bubble").foregroundColor(.black)
                }
                .tag(1)
            ProfileView(currentViewShowing: $currentViewShowing)
                .environmentObject(topic)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle").foregroundColor(.black)
                }
                .tag(2)
        }
        .onChange(of: motionManager.deviceMotion) { motion in
                    guard let motion = motion else { return }
                    let roll = motion.attitude.roll
                    if roll > 0.2 {
                        selectedTab = 2
                    } else if roll < -0.2 {
                        selectedTab = 0
                    } else if abs(roll) < 0.2 {
                        selectedTab = 1
                    }
                    print(roll)
                }
        .onAppear {
                    motionManager.startDeviceMotionUpdates()
                }
        .onDisappear {
                    motionManager.stopDeviceMotionUpdates()
                }
    }
}
