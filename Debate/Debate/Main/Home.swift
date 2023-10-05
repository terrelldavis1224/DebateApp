//
//  Home.swift
//  Debate_App
//
//  Created by Phuoc Nguyen on 3/31/23.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var topicList: TopicList
    var body: some View {
            ZStack {
                NavigationView {
                    VStack {
                        Text("Debate Topics")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .bold()
                        ScrollView {
                            VStack {
                                ForEach(topicList.list, id:\.self) {
                                    topic in
                                    NavigationLink(destination: SelectView(question: topic.questions, topic: topic).environmentObject(topicList).navigationTitle(Text(topic.title))) {
                                        Text(topic.title)
                                    }
                                    .tint(.mint)
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.roundedRectangle(radius: 8))
                                    .controlSize(.large)
                                    .padding()
                                    .shadow(color: Color(red: 95 / 255, green: 191 / 255, blue: 194 / 255), radius: 8, x: 1,y: 1)
                                }
                            }
                        }
                    }
                }
            }
        }
}


