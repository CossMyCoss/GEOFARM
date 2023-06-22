//
//  AuthViewModel.swift
//  
//
//  Created by Cosmin Calaianu on 30.03.2023.
//

import Foundation
import SwiftUI
import Firebase



class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        
        print("DEBUG: User session is \(String(describing: self.userSession))")
    }
    
    func login(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG:Loginul nu a functionat cu eroarea \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {return}
            self.userSession = user
            
        }
    }
    
    func signOut(){
        userSession = nil
         try? Auth.auth().signOut()
    }
    
}
