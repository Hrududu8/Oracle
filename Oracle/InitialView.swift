//
//  SwiftUIView.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import SwiftUI
import FoundationModels

struct InitialView: View {
    
    @Bindable var oracle: Oracle
    
    var body: some View {
        if oracle.checkAvailability().isAvailable {
            OracleView(oracle: oracle)
        } else {
            switch oracle.checkAvailability().reason {
            case "Model not ready":
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            default:
                Text(oracle.checkAvailability().reason)
            }
        }
        
    }
}

#Preview {
    let oracle = Oracle()
    InitialView(oracle: oracle)
}
