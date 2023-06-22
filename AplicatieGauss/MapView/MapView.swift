//
//  MapView.swift
//
//
//  Created by Calaianu Cosmin on 24.03.2023.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase
import Combine



struct MapView: View{
    
    @State private var showMenuView = false
    @State private var showPhotosView = false
    @State private var showFullScreenCover: Bool = false
    @State public var selectedFeatureProperties: [String: Any] = [:]
    @State private var features: [CustomGeoJSONFeature] = []
    @State private var isFirstLaunch = true
    @State private var isExplicitRegionChange = false
    @State private var mapType: MKMapType = .standard
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var detaliiFermierViewModel = DetaliiFermierViewModel()
    
    
    
    
    var body: some View{
        
        ZStack {
            
            CustomMapView(isFirstLaunch: $isFirstLaunch,
                          isExplicitRegionChange: $isExplicitRegionChange,
                          region: $viewModel.region,
                          locationManager: viewModel.locationManager,
                          features: $features,
                          mapType: $mapType,
                          onOverlayTap: { index in
                detaliiFermierViewModel.selectedFeatureIndex = index
                withAnimation {
                    showFullScreenCover = true
                }
            }
            )
            .ignoresSafeArea()
            .accentColor(Color(.systemBlue))
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
                viewModel.fetchPolygonsFromFirestore { (features) in
                    let newFeatures = viewModel.featuresToOverlays(features)
                    print("\(newFeatures.count) new features")
                    self.features = newFeatures
                    self.detaliiFermierViewModel.features = newFeatures
                }
            }
            
            HStack{
                
                VStack {
                    
                    Button {
                        withAnimation {
                            showMenuView.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 35, height: 35)
                            .padding()
                    }
                    .opacity(showFullScreenCover ? 0 : 1)
                    .background(.white.opacity(0))
                    .foregroundColor(.cyan)
                    .clipShape(Circle())
                    .padding(.leading, 20)
                    .shadow(radius: 10)
                    
                    Spacer()
                        .frame(height: 600)
    
                }
                
                Spacer()
                
                VStack{
                    
                    Spacer()
                        .frame(height: 150)
                    
                    Button {
                        viewModel.region.span.latitudeDelta *= 0.5
                        viewModel.region.span.longitudeDelta *= 0.5
                        isExplicitRegionChange = true
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.cyan)
                            .padding()
                    }
                    .shadow(radius: 10)
                    .opacity(showFullScreenCover ? 0 : 1)
                    .padding(.leading, 50)
                    
                    Button {
                        viewModel.region.span.latitudeDelta /= 0.5
                        viewModel.region.span.longitudeDelta /= 0.5
                        isExplicitRegionChange = true
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.cyan)
                            .padding()
                    }
                    .shadow(radius: 10)
                    .opacity(showFullScreenCover ? 0 : 1)
                    .padding(.leading, 50)
                    
                    Button {
                        switch mapType {
                        case .standard: mapType = .hybrid
                        case .hybrid: mapType = .satellite
                        case .satellite: mapType = .standard
                        default: mapType = .standard
                        }
                    } label: {
                        Image(systemName: "map.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.cyan)
                            .padding()
                    }
                    .padding(.leading, 50)
                    .opacity(showFullScreenCover ? 0 : 1)
                    
                    Spacer()
                        .frame(height: 150)
                    
                    Button {
                        print("Button pressed")
                        if let nearestOverlay = viewModel.getNearestOverlay(features: self.features) {
                            let center = nearestOverlay.coordinate
                            print("Nearest Overlay: \(center)")
                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            viewModel.region = MKCoordinateRegion(center: center, span: span)
                            print("Updated Region: \(viewModel.region)")
                        } else {
                            print("Can't find nearest overlay")
                        }
                        isExplicitRegionChange = true
                    } label: {
                        Image(systemName: "p.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.cyan)
                            .padding()
                    }
                    .opacity(showFullScreenCover ? 0 : 1)
                    .padding(.leading,50)
                    
                    Button {
                        viewModel.setRegionToUserLocation()
                        isExplicitRegionChange = true
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.cyan)
                            .padding()
                    }
                    .opacity(showFullScreenCover ? 0 : 1)
                    .padding(.leading, 50)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            .opacity(showFullScreenCover ? 0 : 1)
            
            if showMenuView {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenuView = false
                        }
                    }
                
                HStack {
                    SideMenuView(showMenuView: $showMenuView)
                        .environmentObject(detaliiFermierViewModel)
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .background(Color.white)
                        .transition(.move(edge: .leading))
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .overlay(
            Group {
                if showFullScreenCover {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showFullScreenCover = false
                        }
                    
                    DetaliiFermierView(viewModel: detaliiFermierViewModel)
                        .frame(width: 350, height: 530)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: 100)
                        .dismissOnOutsideTap(isPresented: $showFullScreenCover)
                }
            }
        )
        
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

