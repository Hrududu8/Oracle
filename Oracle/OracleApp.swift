//
//  OracleApp.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import SwiftUI

@main
struct OracleApp: App {
    var body: some Scene {
        let oracle = Oracle()
        WindowGroup {
            InitialView(oracle: oracle)
        }
    }
}
