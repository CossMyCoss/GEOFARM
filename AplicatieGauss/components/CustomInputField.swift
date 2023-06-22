//
//  CustomInputField.swift
//  
//
//  Created by Cosmin Calaianu on 30.03.2023.
//

import SwiftUI

struct CustomInputField: View {
    let imageName: String
    let placeHolderText: String
    var isSecuredField: Bool? = false
    @Binding var text: String
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(.darkGray))
                
                if isSecuredField ?? false{
                    SecureField(placeHolderText, text: $text)
                        .foregroundColor(Color(.black))
                } else {
                    TextField(placeHolderText, text: $text)
                        .foregroundColor(Color(.black))
                }
            }
            Divider()
                .background(Color(.darkGray))
        }
    }
}

struct CustomInputField_Previews: PreviewProvider {
    static var previews: some View {
        CustomInputField(imageName: "envelope",
                         placeHolderText: "Email",
                         isSecuredField: false ,
                         text: .constant(""))
        
    }
}
