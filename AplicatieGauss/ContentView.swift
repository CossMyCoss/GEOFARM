//
//  ContentView.swift
//  
//
//  Created by Calaianu Cosmin on 24.03.2023.
//

import SwiftUI
import MapKit
import Firebase


struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        
        
        Group{
            if viewModel.userSession == nil {
                LogInView
            } else{
                mainInterfaceView
                    .onAppear()
                
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView{
    var mainInterfaceView: some View{
        MapView()
    }
}

extension ContentView{
    var LogInView: some View{
        LoginView()
    }
}
