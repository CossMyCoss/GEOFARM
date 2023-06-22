//
//  CautaFermierView.swift
//  AplicatieGauss
//
//  Created by Cosmin Calaianu on 18.04.2023.
//

import SwiftUI

struct CautaFermierView: View {
    
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: DetaliiFermierViewModel
    @State private var showDetaliiFermierView = false
    @State private var searchText = ""
    @State private var numberOfRows = 25
    
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                
                Spacer()
                    .frame(height: 60)
                
                HStack{
                    Button {
                        viewModel.searchText = ""
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 16)
                            .foregroundColor(.gray)
                            .offset(x: 16, y: 12)
                            .opacity(showDetaliiFermierView ? 0 : 1)
                    }
                    
                    
                    Spacer()
                }
                .padding()
                
                
                VStack{
                    SearchBar(text: $viewModel.searchText)
                        .padding()
                    
                    
                    ScrollView{
                        LazyVStack{
                            
                            ForEach(viewModel.filteredFeatures.prefix(numberOfRows).indices, id: \.self) { index in
                                Button(action: {
                                    if !viewModel.searchText.isEmpty {
                                        viewModel.selectedFilteredFeatureIndex = index
                                    } else {
                                        viewModel.selectedFeatureIndex = index
                                    }
                                    withAnimation {
                                        showDetaliiFermierView = true
                                    }
                                }) {
                                    FermierRowView(feature: viewModel.filteredFeatures[index])
                                }
                            }
                            
                            
                            HStack {
                                if viewModel.features.count > numberOfRows && !viewModel.filteredFeatures.isEmpty {
                                    Button(action: {
                                        numberOfRows += 10
                                    }) {
                                        Text("Load more")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                }
                                
                                Spacer()
                                    .frame(maxWidth: 20)
                            }
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
                
            }
            .overlay(
                Group {
                    if showDetaliiFermierView {
                        Color.black.opacity(0.6)
                            .onTapGesture {
                                withAnimation {
                                    showDetaliiFermierView = false
                                }
                            }
                        
                        DetaliiFermierView(viewModel: viewModel)
                            .frame(width: 350, height: 530)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                            .animation(.easeIn, value: 80)
                            .dismissOnOutsideTap(isPresented: $showDetaliiFermierView)
                    }
                }
            )
            .ignoresSafeArea()
            .background(Color.white)
        }
    }
}

//struct CautaFermierView_Previews: PreviewProvider {
//    static var previews: some View {
//        CautaFermierView()
//    }
//}
