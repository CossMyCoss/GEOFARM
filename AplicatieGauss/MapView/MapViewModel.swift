//
//  MapViewModel.swift
//  
//
//  Created by Cosmin Calaianu on 05.04.2023.
//

import MapKit
import CoreLocation
import Firebase



final class MapViewModel: NSObject, ObservableObject,
                          CLLocationManagerDelegate{
    
    
    @Published var region = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(latitude: 45.7494, longitude: 21.2272),
                                               span:MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    var locationManager: CLLocationManager?
    private let db = Firestore.firestore()
    
    
    override init(){
        super.init()
        locationManager?.delegate=self
        
    }
    
    func checkIfLocationServicesIsEnabled(){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            checkLocationAuthorization()
        } else {
            print("User's device has the location services off")
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else { return  }
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location services restricted")
        case .denied:
            print("locations services are denied")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            } else {
                print("Unable to get location")
            }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func setRegionToUserLocation() {
        guard let userLocation = locationManager?.location?.coordinate else {
            print("Can't get user's location")
            return
        }
        region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    
    func getNearestOverlay(features: [CustomGeoJSONFeature]) -> MKOverlay? {
        guard let userLocation = locationManager?.location?.coordinate else {
            print("Can't get user's location")
            return nil
        }
        
        var nearestOverlay: MKOverlay? = nil
        var smallestDistance: CLLocationDistance = .greatestFiniteMagnitude
        
        for feature in features {
            for overlay in feature.overlays {
                if let polygon = overlay as? MKPolygon {
                    let renderer = MKPolygonRenderer(polygon: polygon)
                    let overlayCenterMapPoint = MKMapPoint(x: renderer.polygon.boundingMapRect.midX, y: renderer.polygon.boundingMapRect.midY)
                    let overlayCenterLocation = CLLocation(latitude: overlayCenterMapPoint.coordinate.latitude, longitude: overlayCenterMapPoint.coordinate.longitude)
                    
                    let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let distance = userLocation.distance(from: overlayCenterLocation)
                    
                    if distance < smallestDistance {
                        smallestDistance = distance
                        nearestOverlay = overlay
                    }
                }
            }
        }
        
        return nearestOverlay
    }
    
    
    func fetchPolygonsFromFirestore(completion: @escaping ([CustomGeoJSONFeature]) -> Void) {
        
        let polygonsCollection = db.collection("polygonsTEST").order(by: "PARCEL_NR")
        var geoJSONFeatures: [CustomGeoJSONFeature] = []
        
        polygonsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Can't get any document")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("Can't find any document")
                completion([])
                return
            }
            
            for document in documents {
                let data = document.data()
                guard let coordinatesData = data["coordinates"] as? [GeoPoint] else {
                    print("Can't get coordinates")
                    continue
                }
                
                let coordinates = coordinatesData.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                
                let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
                let multiPolygon = MKMultiPolygon([polygon])
                
                let properties = data.filter { (key, _) -> Bool in
                    return key != "coordinates"
                }
                
                let propertiesData: Data
                do {
                    propertiesData = try JSONSerialization.data(withJSONObject: properties, options: [])
                } catch {
                    print("Error deserializing")
                    continue
                }
                
                let customGeoJSONFeature = CustomGeoJSONFeature(geometry: [multiPolygon], properties: propertiesData, documentID: document.documentID)
                geoJSONFeatures.append(customGeoJSONFeature)
            }
            
            completion(geoJSONFeatures)
        }
    }
    
    
    func featuresToOverlays(_ features: [CustomGeoJSONFeature]) -> [CustomGeoJSONFeature] {
        var featuresWithOverlays: [CustomGeoJSONFeature] = []
        
        for feature in features {
            var overlays: [MKOverlay] = []
            for geo in feature.geometry {
                if let multiPolygon = geo as? MKMultiPolygon {
                    for polygon in multiPolygon.polygons {
                        overlays.append(polygon)
                    }
                } else {
                    print("Not a multipolygon")
                }
            }
            feature.overlays = overlays
            featuresWithOverlays.append(feature)
        }
        
        return featuresWithOverlays
    }
    
    
    func updatePolygonsInFirestore(features: [CustomGeoJSONFeature], completion: @escaping (Error?) -> Void) {
        let polygonsCollection = db.collection("polygonsTEST")
        let batch = db.batch()

        for feature in features {
            var properties: [String: Any]
            if let propertiesData = feature.properties,
               let propertiesDict = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                properties = propertiesDict
            } else {
                print("Error serializing properties from data")
                continue
            }

            // Transform the coordinates into GeoPoints
            if let multiPolygon = feature.geometry.first as? MKMultiPolygon,
               let polygon = multiPolygon.polygons.first {
                let coordinates = extractCoordinates(from: polygon)
                let geoPoints = coordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
                properties["coordinates"] = geoPoints
            } else {
                print("Could not extract polygon from feature geometry.")
                continue
            }

            // We use the PARCEL_NR as the documentID
            if let documentID = feature.documentID {
                let documentRef = polygonsCollection.document(documentID)
                batch.updateData(properties, forDocument: documentRef)
                //                batch.setData(properties, forDocument: documentRef)
            } else {
                print("No documentID found in feature")
                continue
            }
        }

        batch.commit { (error) in
            completion(error)
        }
    }
    
    
    func extractCoordinates(from polygon: MKPolygon) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: polygon.pointCount)
        polygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: polygon.pointCount))
        return coordinates
    }
     
    
    
    func uploadDataToFirestore() {
        print("uploadDataToFirestore called")
        guard let url = Bundle.main.url(forResource: "Geojson_1000", withExtension: "geojson") else {
            fatalError("Unable to get geojson")
        }
        var geoJson: [MKGeoJSONObject] = []
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
        } catch {
            fatalError("Unable to decode")
        }
        
        for item in geoJson {
            print("Processing geoJson item")
            if let feature = item as? MKGeoJSONFeature {
                var propertiesDict: [String: Any] = [:]
                if let propertiesData = feature.properties {
                    do {
                        if let properties = try JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                            for (key, value) in properties {
                                propertiesDict[key] = value
                            }
                        }
                    } catch {
                        print("Error parsing properties data: \(error)")
                    }
                }
                
                for geo in feature.geometry {
                    print("Processing geometry item")
                    if let multiPolygon = geo as? MKMultiPolygon {
                        if let polygon = multiPolygon.polygons.first {
                            let geopoints = polygonToGeopoints(polygon)
                            let geoPointArray = geopoints.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
                            propertiesDict["coordinates"] = geoPointArray
                            
                            let docRef = db.collection("polygons1000").document()
                            docRef.setData(propertiesDict) { error in
                                if let error = error {
                                    print("Error writing document: \(error)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        } else {
                            print("MultiPolygon has no polygons")
                        }
                    } else {
                        print("Geometry item is not a multipolygon")
                    }
                }
            } else {
                print("GeoJSON item is not a feature")
            }
        }
    }
    
    func polygonToGeopoints(_ polygon: MKPolygon) -> [CLLocationCoordinate2D] {
        let pointCount = polygon.pointCount
        var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: pointCount)
        polygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))
        return coordinates
    }
    
    
}



