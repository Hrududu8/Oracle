//
//  ContentView.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import SwiftUI
import FoundationModels

struct OracleView: View {
    
    @State var oracle: Oracle
    @State var prompt = ""
    @State var response = ""
    
    var body: some View {
        VStack {
            TextField("Prompt", text: $prompt, axis: .vertical)
                .lineLimit(5...10)
                .textFieldStyle(.roundedBorder)
            Button("Generate") {
                Task {
                    response = await oracle.generateResponse(to: prompt)
                }
            }
            .disabled(prompt.isEmpty || oracle.session.isResponding)
            
            ScrollView {
                if oracle.session.isResponding {
                    ProgressView()
                } else {
                    Text(.init(response))
                }
            }
        }
        .padding()
    }
}


#Preview {
    let oracle = Oracle()
    OracleView(oracle: oracle)
}
