//
//  DetaliiFermierView.swift
//  AplicatieGauss
//
//  Created by Cosmin Calaianu on 19.04.2023.
//

import SwiftUI
import PhotosUI

struct DetaliiFermierView: View {
    
    @ObservedObject var viewModel: DetaliiFermierViewModel
    @Environment(\.presentationMode) var mode
    @State private var isEditingLayer = false
    @State private var editedLayerValue = ""
    @State private var isEditingDataType = false
    @State private var editedDataTypeValue = ""
    @State var selectedItems: [PhotosPickerItem] = []
    @State var data: Data?
    @State private var isPresentingImageViewer = false
    @State var featureImageUrls: [String] = []
    
    
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
           // ScrollView{
                    
                    VStack(alignment: .center){
                        
                        Spacer()
                            .frame(height: 40)
                        
                        let selectedFeatureIndex = viewModel.selectedFilteredFeatureIndex ?? viewModel.selectedFeatureIndex
                        
                        let featuresToUse = viewModel.selectedFilteredFeatureIndex != nil ? viewModel.filteredFeatures : viewModel.features
                        
                        if let selectedFeatureIndex = selectedFeatureIndex {
                            let selectedFeature = featuresToUse[selectedFeatureIndex]
                            if let propertiesData = selectedFeature.properties,
                               let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                                
                                let imageUrls = properties["imageUrls"] as? [String]
                                
                                VStack{
                                    if let imageUrls = imageUrls, !imageUrls.isEmpty, let url = URL(string: imageUrls.first!) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
                                                .frame(width: 150, height: 150)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    } else {
                                        Image("parcel")
                                            .resizable()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
                                            .frame(width: 150, height: 150)
                                    }
                                    
                                    
                                    HStack {
                                        Text("ID FERMIER: ")
                                            .bold()
                                            .font(.title)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["PARCEL_NR"] ?? "N/A"))")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                    .frame(height: 30)
                                
                                VStack{
                                    
                                    if isEditingLayer {
                                        HStack{
                                            
                                            TextField("LAND TYPE:", text: $editedLayerValue)
                                                .foregroundColor(.black)
                                                .autocorrectionDisabled()
                                                .textInputAutocapitalization(.never)
                                            Button {
                                                isEditingLayer = false
                                                var mutableProperties = properties
                                                mutableProperties["LAYER"] = editedLayerValue
                                                if let updatedPropertiesData = try? JSONSerialization.data(withJSONObject: mutableProperties) {
                                                    let mutableSelectedFeature = selectedFeature
                                                    mutableSelectedFeature.properties = updatedPropertiesData
                                                    
                                                    if let selectedFeatureIndex = viewModel.selectedFeatureIndex {
                                                        viewModel.features[selectedFeatureIndex] = mutableSelectedFeature
                                                    }
                                                    
                                                    if let selectedFilteredFeatureIndex = viewModel.selectedFilteredFeatureIndex {
                                                        viewModel.filteredFeatures[selectedFilteredFeatureIndex] = mutableSelectedFeature
                                                    }
                                                    
                                                    viewModel.updateFeatureInFirestore(mutableSelectedFeature) { error in
                                                        if let error = error {
                                                            print("Couldn't update feature in Firestore: \(error)")
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.gray)
                                                    .bold()
                                            }
                                            
                                        }
                                    } else {
                                        HStack{
                                            
                                            Text("LAND TYPE: ")
                                                .bold()
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text("\(String(describing: properties["LAYER"] ?? "N/A"))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Button {
                                                isEditingLayer = true
                                                editedLayerValue = properties["LAYER"] as? String ?? ""
                                            } label: {
                                                Image(systemName: "slider.vertical.3")
                                                    .foregroundColor(.gray)
                                                    .bold()
                                            }
                                        }
                                    }
                                    
                                    if isEditingDataType {
                                        HStack{
                                            
                                            TextField("CROP TYPE", text: $editedDataTypeValue)
                                                .foregroundColor(.black)
                                                .autocorrectionDisabled()
                                                .textInputAutocapitalization(.never)
                                            Button {
                                                isEditingDataType = false
                                                var mutableProperties = properties
                                                mutableProperties["DataType"] = editedDataTypeValue
                                                if let updatedPropertiesData = try? JSONSerialization.data(withJSONObject: mutableProperties) {
                                                    let mutableSelectedFeature = selectedFeature
                                                    mutableSelectedFeature.properties = updatedPropertiesData
                                                    
                                                    if let selectedFeatureIndex = viewModel.selectedFeatureIndex {
                                                        viewModel.features[selectedFeatureIndex] = mutableSelectedFeature
                                                    }
                                                    
                                                    if let selectedFilteredFeatureIndex = viewModel.selectedFilteredFeatureIndex {
                                                        viewModel.filteredFeatures[selectedFilteredFeatureIndex] = mutableSelectedFeature
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.gray)
                                                    .bold()
                                            }
                                        }
                                    } else {
                                        HStack{
                                            
                                            Text("CROP TYPE: ")
                                                .bold()
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text("\(String(describing: properties["DataType"] ?? "N/A"))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Button {
                                                isEditingDataType = true
                                                editedDataTypeValue = properties["DataType"] as? String ?? ""
                                            } label: {
                                                Image(systemName: "slider.vertical.3")
                                                    .foregroundColor(.gray)
                                                    .bold()
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text("JUDET: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["JUDET"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("BLOC_NR: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["BLOC_NR"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("FARM_ID: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["FARM_ID"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("CROP_CODE: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["CROP_CODE"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("CROP_NR: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["CROP_NR"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("SIRSUP_COD: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["SIRSUP_COD"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("U_Farm_Id: ")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(String(describing: properties["U_Farm_Id"] ?? "N/A"))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                    .frame(height: 10)
                                
                                HStack {
                                    
                                    if let imageUrls = imageUrls, !imageUrls.isEmpty {
                                        Button(action: {
                                            isPresentingImageViewer = true
                                        }) {
                                            Image(systemName: "photo.circle.fill")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .foregroundColor(.green)
                                                .padding()
                                        }
                                        .fullScreenCover(isPresented: $isPresentingImageViewer) {
//                                            ImageViewer(imageUrls: imageUrls)
                                            ImageViewer(detaliiFermierViewModel: viewModel, selectedFeatureIndex: selectedFeatureIndex, imageUrls: imageUrls)

                                            
                                        }
                                    }
                                    
                                    if let imageUrls = imageUrls, !imageUrls.isEmpty {
                                        Spacer()
                                            .frame(width: 30)
                                    }
                                    
                                    
                                    PhotosPicker(
                                        selection: $selectedItems,
                                        maxSelectionCount: 5,
                                        matching: .images
                                    ) {
                                        Image("import")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.green)
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .padding()
                                    }
                                    .onChange(of: selectedItems) { newValue in
                                        guard let item = selectedItems.first else{
                                            return
                                        }
                                        item.loadTransferable(type: Data.self) { result in
                                            DispatchQueue.main.async {
                                                switch result {
                                                case .success(let data):
                                                    if let data = data {
                                                        self.data = data
                                                        viewModel.saveImageToFeature(data: data, for: viewModel.selectedFeatureIndex)
                                                    } else {
                                                        print("Data is nil")
                                                    }
                                                case .failure(let failure):
                                                    fatalError("\(failure)")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
            //}
        }
    }
}

struct DetaliiFermierView_Previews: PreviewProvider {
    static var previews: some View {
        DetaliiFermierView(viewModel: DetaliiFermierViewModel())
    }
}
