//
//  ContentView.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var oracle = Oracle()
    @State var prompt = ""
    @State var response = ""
    
    var body: some View {
        if oracle.checkAvailability() != nil {
            Text("oracle not available") // need to say why
        } else {
            
            
            VStack {
                TextField("Prompt", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                Button("Generate") {
                    Task {
                        response = await oracle.generateResponse(to: prompt)
                    }
                }
                .disabled(prompt.isEmpty)
                
                ScrollView {
                    Text(response)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
