//
//  FermierRowView.swift
//  
//
//  Created by Cosmin Calaianu on 18.04.2023.
//

import SwiftUI

struct FermierRowView: View {
    let feature: CustomGeoJSONFeature
    
    var body: some View {
        HStack(spacing: 12){
            
            VStack(alignment: .leading, spacing: 4){
                if let propertiesData = feature.properties,
                   let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                    
                    HStack{
                        
                        let imageUrls = properties["imageUrls"] as? [String]
                        
                        if let imageUrls = imageUrls, !imageUrls.isEmpty, let url = URL(string: imageUrls.first!) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
                                    .frame(width: 44, height: 44)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image("parcel")
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
                                .frame(width: 44, height: 44)
                        }
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text("ID FERMIER: \(String(describing: properties["PARCEL_NR"] ?? "N/A"))")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.black)
                            
                            Text("JUDET: \(String(describing: properties["JUDET"] ?? "N/A"))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}


//struct FermierRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        FermierRowView()
//    }
//}
