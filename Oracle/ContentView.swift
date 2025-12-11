//
//  ContentView.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    @State var evaluator = LLMEvaluator()
    @State var userPrompt = ""
    
    var body: some View {
        VStack {
            TextField("Ask something...", text: $userPrompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Generate") {
                Task {
                    await evaluator.generate(prompt: userPrompt)
                }
            }
            
            ScrollView {
                Text(evaluator.output)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
