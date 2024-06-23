//
//  MarkerCenterMap.swift
//  SinTraffic
//
//  Created by pc on 29/05/2024.
//

import Foundation
import SwiftUI
import GoogleMaps

struct MarkerCenterMap: Codable {
    var name: String = "MarkerCenterMap"
}

extension MarkerCenterMap: MarKerData {
    func getPosition() -> CLLocationCoordinate2D {
        let centerPoint = MapMange.share.centerPoint
        return CLLocationCoordinate2D(latitude: centerPoint.lat, longitude: centerPoint.long)
    }
    
    func getIconType() -> MarkerIconType {
        .CENTERMAP
    }
    
    func getTitle() -> String {
        name
    }
    
    func getIconView() -> AnyView {
        return AnyView(CenterMapIconMarkerView())
    }
}

struct CenterMapIconMarkerView: View {
    var body: some View {
        ZStack {
            Text("Please move to Singapore")
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .padding(3)
                .padding(.horizontal, 5)
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.black)
                }
                .padding(.bottom, 35)
                
            Image(systemName: "mappin")
                .opacity(0.8)
                .font(.caption)
        }
        .background(.clear)
        
    }
}
