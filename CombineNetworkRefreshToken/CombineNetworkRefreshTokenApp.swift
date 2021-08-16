//
//  CombineNetworkRefreshTokenApp.swift
//  CombineNetworkRefreshToken
//
//  Created by Inpyo Hong on 2021/08/16.
//

import SwiftUI

@main
struct CombineNetworkRefreshTokenApp: App {
    var networkManager = NetworkManager(session: MockNetworkSession())
    
    init() {
       _ = networkManager.performAuthenticatedRequest()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
