//
//  PolygonService.swift
//  AplicatieGauss
//
//  Created by Cosmin Calaianu on 09.05.2023.
//

import Firebase
import FirebaseFirestoreSwift

struct PolygonService{
  
    func fetchPolygons(completion: @escaping ([MKOverlay]) -> Void) {
        Firestore.firestore().collection("polygons")
        
}


//func parseGeoJSON() -> [MKOverlay] {
//    guard let url = Bundle.main.url(forResource: "mapOverlay", withExtension: "json") else {
//        fatalError("Unable to get geojson")
//    }
//    var geoJson = [MKGeoJSONObject]()
//    do {
//        let data = try Data(contentsOf: url)
//        geoJson = try MKGeoJSONDecoder().decode(data)
//    } catch {
//        fatalError("Unable to decode")
//    }
//
//    var overlays = [MKOverlay]()
//    for item in geoJson {
//        if let feature = item as? MKGeoJSONFeature {
//            for geo in feature.geometry {
//                if let polygon = geo as? MKPolygon {
//                    overlays.append(polygon)
//                } else if let multiPolygon = geo as? MKMultiPolygon {
//                    overlays.append(contentsOf: multiPolygon.polygons)
//                }
//            }
//        }
//    }
//    return overlays
//}
//
//
//func fetchOverlaysFromFirestore(completion: @escaping ([MKOverlay]) -> Void) {
//print("Fetching overlays from Firestore")
//db.collection("polygons").getDocuments { querySnapshot, error in
//    if let error = error {
//        print("Error getting documents: \(error)")
//        completion([])
//    } else {
//        var overlays: [MKOverlay] = []
//
//        for document in querySnapshot!.documents {
//            print("Processing document: \(document.documentID)")
//
//            if let coordinatesDict = document.data()["coordinates"] as? [String: GeoPoint] {
//                print("Fetched coordinates: \(coordinatesDict)")
//
//                let coordinates = coordinatesDict.values.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
//                let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
//                overlays.append(polygon)
//            }
//        }
//
//        print("Finished fetching overlays")
//        completion(overlays)
//    }
//}
//}
