//
//  QuestionView.swift
//  Debate_App
//
//  Created by Aarav Naveen on 3/31/23.
//

import SwiftUI

struct AddQuestion: View {
    @EnvironmentObject var topicList: TopicList
    @State private var userInput: String = ""
    @Environment(\.dismiss) var dismiss
    
    let questions: [String]
    let topic: Topic
    init (question: [String], topic: Topic) {
        self.questions = question
        self.topic = topic
    }
    
    var body: some View {
        VStack {
            TextField("Enter your debate question:", text: $userInput)
                .frame(width: 300)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 2)
                }
            Button(action: {
                topicList.addQuestion(topic: topic, question: userInput)
                dismiss()
            }) {
                Text("Add")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        
    }
}

struct SelectButton: View {
    @Binding var isSelected: Bool
    @State var color: Color
    @State var text: String
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(height: 50)
                .foregroundColor(isSelected ? color : .gray)
                .clipShape(Circle())
            Text(text)
                .foregroundColor(.white)
            
        }
    }
}

struct SelectView: View {
    @EnvironmentObject var topicList: TopicList
    @State private var curr = ""
    @State private var i = 0
    @State private var selections: [Bool]
    @State private var isSelected = false
    @State private var showAlert = false
    @State private var alertText = ""
    
    let topicQuestions: [String]
    let topic: Topic
    
    init (question: [String], topic: Topic) {
        self.topicQuestions = question
        self.topic = topic
        selections = [Bool](repeating: false, count: question.count)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack (alignment: .leading) {
                            
                            ForEach(topicQuestions, id: \.self) { question in
                                VStack {
                                    Text(question)
                                        .font(.title3.weight(.semibold))
                                        .padding()
                                        .foregroundColor(.white)
                                    
                                    SelectButton(isSelected: $selections[topicQuestions.firstIndex(of: question)!], color: .red, text: "Select")
                                        .onTapGesture {
                                            i = topicQuestions.firstIndex(of: question)!
                                            selections = selections.map { _ in false }
                                            selections[i].toggle()
                                            curr = question
                                            isSelected = true
                                        }
                                }
                                .frame(width: 350)
                                .background(.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            if isSelected{
                NavigationLink(destination: DebateView(question: curr, topic: topic.title).navigationTitle(Text(curr))) {
                    Text("Search")
                }.frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
    
    struct QuestionView: View {
        @EnvironmentObject var topicList: TopicList
        @State private var isPresented: Bool = false
        
        let topicQuestions: [String]
        let topic: Topic
        
        init (question: [String], topic: Topic) {
            self.topicQuestions = question
            self.topic = topic
        }
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(topicQuestions, id:\.self) {
                            questions in
                            VStack {
                                Text(questions)
                                    .font(.title3.weight(.semibold))
                                    .padding()
                                    .foregroundColor(.white)
                                NavigationLink(destination: History().environmentObject(topicList).navigationTitle(Text(questions))) {
                                    Text("View")
                                        .frame(width: 200)
                                        .font(.largeTitle.weight(.semibold))
                                        .foregroundColor(.white)
                                        .background(.orange)
                                        .cornerRadius(8)
                                        .offset(y: -10)
                                }
                            }
                            .frame(width: 350)
                            .background(.blue)
                            .cornerRadius(8)
                        }
                    }
                }
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Text("Create New Debate")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .sheet(isPresented: $isPresented) {
                    AddQuestion(question: topicQuestions, topic: topic)
                        .presentationDetents([.fraction(0.3)])
                }
            }
        }
    }
    
}
