//
//  SearchBar.swift
//  
//
//  Created by Cosmin Calaianu on 17.05.2023.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack{
            TextField("Caută parcela după ID Fermier...", text: $text)
                .padding(8)
                .padding(.horizontal,24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,8)
                    })
        }
        .padding(.horizontal,4)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
            .previewLayout(.sizeThatFits)
    }
}
