//
//  DetaliiFermierViewModel.swift
//  AplicatieGauss
//
//  Created by Cosmin Calaianu on 15.05.2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore



class DetaliiFermierViewModel: ObservableObject {
    @Published var features: [CustomGeoJSONFeature] = [] {
        didSet {
            if searchText.isEmpty {
                filteredFeatures = features
            }
        }
    }
    @Published var selectedFeatureIndex: Int?
    @Published var selectedFilteredFeatureIndex: Int?
    @Published var filteredFeatures: [CustomGeoJSONFeature] = []
    @Published var imageUrls: [String] = []
    
    @Published var searchText = "" {
        didSet {
            if !searchText.isEmpty {
                let searchTerm = String(searchText)
                filteredFeatures = features.filter { feature in
                    if let propertiesData = feature.properties,
                       let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any],
                       let parcelNr = properties["PARCEL_NR"] as? Int {
                        return String(parcelNr).hasPrefix(searchTerm)
                    }
                    return false
                }
                selectedFeatureIndex = nil
            } else {
                filteredFeatures = features
                selectedFilteredFeatureIndex = nil
            }
        }
    }
    
    func saveImageToFeature(data: Data, for selectedFeatureIndex: Int?) {
        let featuresToUse = selectedFilteredFeatureIndex != nil ? filteredFeatures : features
        
        if let selectedFeatureIndex = selectedFeatureIndex {
            let selectedFeature = featuresToUse[selectedFeatureIndex]
            uploadImage(data, for: selectedFeature) { error in
                if let error = error {
                    print("Nu s a putut incarca imaginea: \(error)")
                    return
                }
                print("Imaginea a fost uploadata cu succes")
            }
        }
    }
    
    private func uploadImage(_ data: Data, for feature: CustomGeoJSONFeature, completion: @escaping (Error?) -> Void) {
        let imageName = UUID().uuidString
        let imageUrl = "images/\(imageName)"
        
        let storageRef = Storage.storage().reference().child(imageUrl)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(error)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completion(error)
                        return
                    }
                    self.updateFeature(feature, withImageURL: downloadURL.absoluteString, completion: completion)
                }
            }
        }
    }
    
    private func updateFeature(_ feature: CustomGeoJSONFeature, withImageURL imageURL: String, completion: @escaping (Error?) -> Void) {
        if let propertiesData = feature.properties,
           var properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
            var imageUrls = properties["imageUrls"] as? [String] ?? []
            imageUrls.append(imageURL)
            properties["imageUrls"] = imageUrls
            if let updatedPropertiesData = try? JSONSerialization.data(withJSONObject: properties) {
                feature.properties = updatedPropertiesData
                self.imageUrls = imageUrls
                completion(nil)
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proprietatile updatate nu au putut fi serialiate"])
                completion(error)
            }
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proprietatile nu au putut fi serialiate"])
            completion(error)
        }
    }
    
    func deleteImageAtIndex(_ index: Int, for selectedFeatureIndex: Int?) {
        let featuresToUse = selectedFilteredFeatureIndex != nil ? filteredFeatures : features

        if let selectedFeatureIndex = selectedFeatureIndex {
            let selectedFeature = featuresToUse[selectedFeatureIndex]
            if let propertiesData = selectedFeature.properties,
               var properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                var imageUrls = properties["imageUrls"] as? [String] ?? []
                if index < imageUrls.count {
                    let imageUrlToDelete = imageUrls[index]
                    imageUrls.remove(at: index)
                    properties["imageUrls"] = imageUrls
                    if let updatedPropertiesData = try? JSONSerialization.data(withJSONObject: properties) {
                        selectedFeature.properties = updatedPropertiesData
                        self.imageUrls = imageUrls
                        deleteImageFromStorage(imageUrlToDelete)  // Delete the image from Firebase storage
                    } else {
                        print("Could not serialize updated properties.")
                    }
                }
            }
        }
    }

    private func deleteImageFromStorage(_ imageUrl: String) {
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from storage: \(error)")
            } else {
                print("Image successfully deleted from storage.")
            }
        }
    }
    
    func updateFeatureInFirestore(_ feature: CustomGeoJSONFeature, completion: @escaping (Error?) -> Void) {
        guard let documentID = feature.documentID else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document ID is nil"])
            completion(error)
            return
        }

        guard let propertiesData = feature.properties,
            let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't deserialize feature properties"])
            completion(error)
            return
        }

        let db = Firestore.firestore()
        let featureRef = db.collection("polygons1000").document(documentID)
        featureRef.setData(properties, merge: true) { error in
            completion(error)
        }
    }



    
}

