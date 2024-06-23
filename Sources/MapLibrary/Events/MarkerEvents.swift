//
//  MarkerEvents.swift
//  SinTraffic
//
//  Created by pc on 16/01/2024.
//

import Foundation
import GoogleMaps
import Combine

public enum MarkerEvent {
    case didTap(at: GMSMarker)
    case didTapInfoWindowOf(marker: GMSMarker)
    case didBeginDragging(marker: GMSMarker)
    case didEndDragging(marker: GMSMarker)
    case didDrag(marker: GMSMarker)
    case didChangeMarker(marker: GMSMarker)
}


