//
//  Login View.swift
//  
//
//  Created by Calaianu Cosmin on 24.03.2023.
//

import SwiftUI

struct LoginView: View {
    @State private var email=""
    @State private var password=""
    @State private var isSecured: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {

        VStack{

            HStack {
                
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading){
                        
                        Text("Salut.")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        Text("Bine ai revenit!")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                    }
                    .padding(.vertical)
                    
                    Spacer()
                        .frame(height: 30)
                }
                
                Spacer()
                    .frame(width: 30)
                
                VStack {
                    
                    Spacer()
                    
                    Image("farmer1")
                        .resizable()
                        .frame(width: 190, height: 190)
                        .padding()
                }
                
                
                Spacer()
            }
            .frame(height: 260)
            .padding(.leading)
            .background(Color(.systemGreen))
            .foregroundColor(.white)
            .clipShape(roundedShape(corners: [.bottomRight]))
            
            VStack(spacing: 40){
                
                HStack {
                    CustomInputField(imageName: "envelope",
                                     placeHolderText: "Nume de utilizator/ mail",
                                     text: $email)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 32)
                    .padding(.top, 60)
                    
                    Image(systemName: "eye.slash")
                        .foregroundColor(.gray.opacity(0))
                        .padding()
                }
                
                HStack{
                    if isSecured{
                        
                        CustomInputField(imageName: "lock",
                                         placeHolderText: "Parolă",
                                         isSecuredField: false,
                                         text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        Button {
                            isSecured.toggle()
                        } label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                        }
                    } else {
                        CustomInputField(imageName: "lock",
                                         placeHolderText: "Parolă",
                                         isSecuredField: true,
                                         text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        Button {
                            isSecured.toggle()
                        } label: {
                            Image(systemName: "eye")
                                .foregroundColor(.gray)
                        }.padding()
                    }
                }
                .padding(.horizontal, 32)
                
            }
            Button {
                viewModel.login(withEmail: email, password: password)
            } label: {
                Text("Intră în cont")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 340, height: 50)
                    .background(Color(.systemGreen))
                    .clipShape(Capsule())
                    .padding()
            }
            .shadow(color: .gray.opacity(0.5), radius: 10, x:0, y:0)
            .padding(.top, 60)
            
            Spacer()
        }
        .ignoresSafeArea()
        .background(Color(.white))
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
