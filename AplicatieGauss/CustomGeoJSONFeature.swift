//
//  CustomGeoJSONFeature.swift
//  
//
//  Created by Cosmin Calaianu on 10.05.2023.
//

import Foundation
import MapKit

public class CustomGeoJSONFeature: NSObject, MKGeoJSONObject {
    public let geometry: [MKShape & MKGeoJSONObject]
    public var properties: Data?
    public var overlays: [MKOverlay]
    public var documentID: String?

    public init(geometry: [MKShape & MKGeoJSONObject], properties: Data?, overlays: [MKOverlay] = [], documentID: String? = nil) {
        self.geometry = geometry
        self.properties = properties
        self.overlays = overlays
        self.documentID = documentID
    }
}

