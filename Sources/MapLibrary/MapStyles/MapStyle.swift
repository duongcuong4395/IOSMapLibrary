//
//  MapStyle.swift
//  SinTraffic
//
//  Created by pc on 11/01/2024.
//

import Foundation
import GoogleMaps
import SwiftUI

enum MapSizeState {
    case fullScreen
    case halfScreen
    
    func getMapSize() -> CGFloat {
        switch self {
        case .fullScreen:
            return 0 //UIScreen.main.bounds.height/3 // 0 //UIScreen.main.bounds.height/13
        case .halfScreen:
            return UIScreen.main.bounds.height/3 //UIScreen.main.bounds.height/5
        }
    }
}

enum MapStyle {
    case light
    case dark
    
    func getURLStyle() -> GMSMapStyle {
        var fileStyle = ""
        var gMSMapStyle = try? GMSMapStyle(contentsOfFileURL: URL(fileURLWithPath: ""))
        switch self {
        case .dark:
            fileStyle = "MapsStylingNight.geojson"
        case .light:
            fileStyle = "MapsStylingLight.geojson"
        }
        do {
            guard let file = Bundle.main.url(forResource: fileStyle, withExtension: nil)
            else {
                gMSMapStyle = try GMSMapStyle(contentsOfFileURL: URL(fileURLWithPath: ""))
                return gMSMapStyle!
            }
            
            gMSMapStyle = try GMSMapStyle(contentsOfFileURL: file)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        return gMSMapStyle!
    }
    
    func getTextColor() -> Color {
        switch self {
        case .light:
            return .black
        case .dark:
            return .yellow
        }
    }
    func getIconColor() -> Color {
        switch self {
        case .light:
            return .black
        case .dark:
            return .yellow
        }
    }
}
