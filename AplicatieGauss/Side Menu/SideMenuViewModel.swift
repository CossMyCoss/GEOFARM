//
//  SideMenuViewModel.swift
//  
//
//  Created by Cosmin Calaianu on 06.04.2023.
//

import Foundation

enum SideMenuViewModel: Int, CaseIterable {
    case SincronizareFotoSiEditare
    case CautaParcela
    case Iesire
    
    var description: String{
        switch self{
        case .SincronizareFotoSiEditare: return "Sincronizeaza schimbarile..."
        case .CautaParcela: return "Caută Parcelă"
        case .Iesire: return "Ieșire"
        }
    }
    
    var ImageName: String{
        switch self{
        case .SincronizareFotoSiEditare: return "arrow.triangle.2.circlepath.circle.fill"
        case .CautaParcela: return "magnifyingglass.circle.fill"
        case .Iesire: return "arrow.left.square.fill"
        }
    }
}
