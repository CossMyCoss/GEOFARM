//
//  OriginalMapView.swift
//
//
//  Created by Cosmin Calaianu on 27.04.2023.
//

    import SwiftUI
    import MapKit

struct CustomMapView: UIViewRepresentable {
    
    @Binding var isFirstLaunch: Bool
    @Binding var isExplicitRegionChange: Bool
    @Binding var region: MKCoordinateRegion
    var locationManager: CLLocationManager?
    @Binding var features: [CustomGeoJSONFeature]
    @Binding var mapType: MKMapType
    
    
    var onOverlayTap: ((Int) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        if isFirstLaunch {
            mapView.setRegion(region, animated: true)
            isFirstLaunch = false
        }
        context.coordinator.updateOverlays(mapView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if isExplicitRegionChange {
            mapView.setRegion(region, animated: true)
            isExplicitRegionChange = false
        }
        context.coordinator.updateOverlays(mapView)
        mapView.mapType = mapType
    }


    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 1
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
            updateOverlays(mapView)
        }
        
        func updateOverlays(_ mapView: MKMapView) {
            print("updateOverlays called, zoom level: \(zoomLevel(mapView: mapView))")
            DispatchQueue.main.async { [self] in
                let zoom = zoomLevel(mapView: mapView)
                if zoom < 12 {
                    mapView.removeOverlays(mapView.overlays)
                    print("no. of overlays after removal: \(mapView.overlays.count)")
                    return
                }
                
                mapView.removeOverlays(mapView.overlays)
                let visibleMapRect = mapView.visibleMapRect
                let overlays = parent.features
                    .flatMap { $0.overlays }
                    .filter { visibleMapRect.intersects($0.boundingMapRect) }
                mapView.addOverlays(overlays)
            }
        }
        
        func zoomLevel(mapView: MKMapView) -> Double {
            let maxZoom: Double = 21
            let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.bounds.size.width)
            let zoomExponent = log2(zoomScale)
            return maxZoom - zoomExponent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if let mapView = gestureRecognizer.view as? MKMapView {
                print("Features count: \(parent.features.count)")
                let locationInView = gestureRecognizer.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                
                for (index, feature) in parent.features.enumerated() {
                    for overlay in feature.overlays {
                        if let polygon = overlay as? MKPolygon {
                            let renderer = MKPolygonRenderer(polygon: polygon)
                            let mapPoint = MKMapPoint(tappedCoordinate)
                            let rendererPoint = renderer.point(for: mapPoint)
                            if renderer.path.contains(rendererPoint) {
                                if let properties = feature.properties,
                                   let propertiesJSON = try? JSONSerialization.jsonObject(with: properties, options: []) as? [String: Any] {
                                    print("Properties JSON: \(propertiesJSON)")
                                    parent.onOverlayTap?(index)
                                    print("Updated showDetaliiFermierView and selectedFeatureProperties")
                                    return
                                } else {
                                    print("Tapped overlay has no properties")
                                }
                            }
                        }
                    }
                }
                print("No feature found for tapped overlay")
            }
        }
    }
}



