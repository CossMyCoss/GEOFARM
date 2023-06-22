//
//  ImageViewer.swift
//
//
//  Created by Cosmin Calaianu on 23.05.2023.
//

import Foundation
import SwiftUI


struct ImageViewer: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var detaliiFermierViewModel: DetaliiFermierViewModel
    var selectedFeatureIndex: Int
    let imageUrls: [String]
    @State private var selectedImageIndex = 0
    
    var body: some View {
        NavigationView {
            TabView {

                ForEach(imageUrls.indices, id: \.self) { index in
                        Group {
                            if let url = URL(string: imageUrls[index]) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Text("Invalid URL")
                            }
                        }
                        .tag(index)
                    }
            }
            .tabViewStyle(PageTabViewStyle())
            .navigationBarItems(trailing: HStack {
                            Button("Sterge") {
                                detaliiFermierViewModel.deleteImageAtIndex(selectedImageIndex, for: selectedFeatureIndex)
                            }
                            Button("Gata") {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        })
        }
    }
}

