//
//  SideMenuView.swift
//  
//
//  Created by Cosmin Calaianu on 06.04.2023.
//

import SwiftUI

struct SideMenuView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var AuthViewModel: AuthViewModel
    @State private var showCautaParcelaView = false
    @Binding var showMenuView: Bool
    @EnvironmentObject var detaliiFermierViewModel: DetaliiFermierViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @State private var isUploading: Bool = false

    
    
    var body: some View {
        
        ZStack{
            
            VStack(alignment: .leading, spacing: 32){
                
                
                Spacer()
                    .frame(height: 40)
                
                HStack {
                    Button {
                        withAnimation {
                            showMenuView = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .offset(x: 16, y: 12)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                
                Spacer()
                    .frame(height: 40)
                ForEach(SideMenuViewModel.allCases, id: \.rawValue){ viewModel in
                    
                    if viewModel == .SincronizareFotoSiEditare{
                        Button {
                            isUploading = true
                            mapViewModel.updatePolygonsInFirestore(features: detaliiFermierViewModel.features) { (error) in
                                DispatchQueue.main.async {
                                           isUploading = false
                                       }
                                if let error = error {
                                    print("Error updating polygons: \(error)")
                                } else {
                                    print("Polygons updated successfully")
                                }
                            }
                        } label: {
                            SideMenuOptionRowView(viewModel: viewModel)
                        }
                    }else
                    
                    if viewModel == .CautaParcela{
                        Button{
                            withAnimation {
                                showCautaParcelaView.toggle()
                            }
                        } label: {
                            SideMenuOptionRowView(viewModel: viewModel)
                        }
                        .fullScreenCover(isPresented: $showCautaParcelaView) {
                            CautaFermierView()
                                .environmentObject(detaliiFermierViewModel)
                        }
                        
                        
                    }
                    
                    else if viewModel == .Iesire{
                        Button{
                            AuthViewModel.signOut()
                        } label: {
                            SideMenuOptionRowView(viewModel: viewModel)
                        }
                    }
                    
                    else {
                        SideMenuOptionRowView(viewModel: viewModel)
                    }
                }
                
                Spacer()
                
            }
            .background(.white)
            
            if isUploading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.45))
                    .foregroundColor(.white)
            }
        }
        
    }
}

//struct SideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenuView(showMenuView: MapView.$showMenuView)
//    }
//}
