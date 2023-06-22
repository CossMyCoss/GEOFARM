//
//  AplicatieGaussApp.swift
//
//
//  Created by Calaianu Cosmin on 24.03.2023.
//

import SwiftUI
import Firebase


    @main
struct AplicatieGaussApp: App {
    
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView()
            }
            .environmentObject(viewModel)
        }
    }
}
