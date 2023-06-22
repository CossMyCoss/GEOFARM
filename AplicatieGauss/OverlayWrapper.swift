//
//  OverlayWrapper.swift
//  
//
//  Created by Cosmin Calaianu on 10.05.2023.
//

import Foundation
import SwiftUI
import MapKit


public struct OverlayWrapper: Hashable {
    public static func == (lhs: OverlayWrapper, rhs: OverlayWrapper) -> Bool {
        return lhs.overlay === rhs.overlay
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(overlay))
    }

    let overlay: MKOverlay
}
