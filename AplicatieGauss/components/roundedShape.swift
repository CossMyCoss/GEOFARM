//
//  roundedShape.swift
//  
//
//  Created by Calaianu Cosmin on 24.03.2023.
//

import Foundation
import SwiftUI

struct roundedShape: Shape {
    
    var corners: UIRectCorner
    
    func path( in rect: CGRect) -> Path{
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 80, height: 80))
        return Path(path.cgPath)
    }
}
