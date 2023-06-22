//
//  DismissViewOnOutsideTap.swift
//  
//
//  Created by Cosmin Calaianu on 18.05.2023.
//

import Foundation
import SwiftUI
import MapKit


struct DismissViewOnOutsideTap: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .onTapGesture { } 
            .background(tapToDismiss)
    }
    
    private var tapToDismiss: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = false
            }
    }
}

extension View {
    func dismissOnOutsideTap(isPresented: Binding<Bool>) -> some View {
        modifier(DismissViewOnOutsideTap(isPresented: isPresented))
    }
}
