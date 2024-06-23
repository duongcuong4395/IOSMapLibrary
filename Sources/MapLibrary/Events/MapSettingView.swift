//
//  MapSettingView.swift
//  SinTraffic
//
//  Created by pc on 31/01/2024.
//

import Foundation
import SwiftUI

public enum DeviceLocationStatus {
    case Disable
    case Enable
    case Direction
}

public struct MapSettingView: View {
    @EnvironmentObject public var mapVM: MapsViewModel
    @EnvironmentObject public var appVM: AppViewModel
    @EnvironmentObject public var locationManager : LocationManager
    
    @EnvironmentObject public var weatherForecast2HourVM: WeatherForecast2HourViewModel
    @EnvironmentObject public var humidityVM: HumidityViewModel
    @EnvironmentObject public var windDirectionVM: WindDirectionViewModel
    
    
    public var body: some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 55 : 30) {
            Button(action: {
                mapVM.markerVM.clearAllMarker {
                    mapVM.clearInforMarker()
                }
                mapVM.polylineVM.clearAllPolyline()
                mapVM.circleVM.clearCircle(of: .loadRadius)
                
            }, label: {
                Image(systemName: "globe.asia.australia.fill")
                    //.buttonBackgroundDefaultView(appVM: appVM)
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                switchDarkLightMode()
            }, label: {
                Image(systemName: "circle.righthalf.filled")
                    //.buttonBackgroundDefaultView(appVM: appVM)
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                switchShowHideMarkerTitle()
            }, label: {
                Image(systemName: "t.circle")
                    //.buttonBackgroundDefaultView(appVM: appVM)
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                switchDegreeMaps()
            }, label: {
                Image(systemName: "angle")
                    //.buttonBackgroundDefaultView(appVM: appVM)
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                withAnimation {
                    if locationManager.isLocationEnabled {
                        let point = locationManager.location
                        mapVM.moveMapTo(lat: point?.coordinate.latitude ?? 0, long: point?.coordinate.longitude ?? 0, zoom: 14)
                        
                        locationManager.deviceLocationStatus = locationManager.deviceLocationStatus == .Enable ? .Direction : .Enable
                        
                        mapVM.rotateMap(by: locationManager.deviceLocationStatus == .Enable ? 0 : mapVM.mapView.camera.bearing)
                        
                        
                    } else {
                        AppManage.shared.openSettings()
                    }
                    appVM.showĐeviceOnMap = locationManager.isLocationEnabled
                }
            }, label: {
                ZStack {
                    switch locationManager.deviceLocationStatus {
                    case .Disable:
                        Image(systemName: "location")
                        Image(systemName: "questionmark")
                            .font(.caption2)
                            .offset(x: 10)
                    case .Enable:
                        Image(systemName: "location.fill")
                    case .Direction:
                        Image(systemName: "location.north.line.fill")
                    }
                }
                
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                mapVM.markerVM.clearMarkers(by: .WEATHER) {}
                weatherForecast2HourVM.fetch { models in
                    DispatchQueueManager.share.runOnMain {
                        mapVM.addListMarker(from: models)
                    }
                }
            }, label: {
                ZStack {
                    Image(systemName: "cloud.fill")
                        .font(.title2)
                    Text("2h")
                        .font(.caption2)
                        .foregroundStyle(appVM.appMode == .light ? .white : .black)
                        .offset(y: 3)
                }
                
                    //.foregroundStyle(.blue.opacity(0.7))
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                print("relative-humidity API")
                mapVM.markerVM.clearMarkers(by: .HUMIDITY) {}
                humidityVM.fetch { models in
                    DispatchQueueManager.share.runOnMain {
                        mapVM.addListMarker(from: models)
                    }
                }
            }, label: {
                ZStack {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        //.foregroundStyle(.blue.opacity(0.7))
                    Text("%")
                        .font(.caption2.bold())
                        .foregroundStyle(appVM.appMode == .light ? .white : .black)
                        .offset(y: 3)
                }
                
                
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                print("relative-humidity API")
                mapVM.markerVM.clearMarkers(by: .WINDDIRECTION) {}
                windDirectionVM.fetch { models in
                    DispatchQueueManager.share.runOnMain {
                        mapVM.addListMarker(from: models)
                    }
                }
            }, label: {
                ZStack {
                    Image(systemName: "wind")
                        .font(.title2)
                }
                
                
            })
            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            
            Button(action: {
                toggleDrawMap()
            }, label: {
                Image(systemName: "gearshape")
                    .buttonBackgroundDefaultView(appVM: appVM)
            })
            //ButtonGenimiAddKeyView()
              //  .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.7 : 1)
            //TextReaderView()
            
        }
        .foregroundStyle(appVM.appMode == .light ? .black : .white)
        .padding(5)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50, style: .continuous))
        .padding(.trailing, 5)
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }
    
}


extension MapSettingView {
    func switchDarkLightMode() {
        MapMange.share.mapStyle = MapMange.share.mapStyle == .dark ? .light : .dark
        appVM.appMode = appVM.appMode == .dark ? .light : .dark
        mapVM.updateMapStyle()
    }
    
    func switchShowHideMarkerTitle() {
        MapMange.share.showTitle.toggle()
        mapVM.refreshIconMarker()
    }
    
    func switchDegreeMaps() {
        mapVM.changeMapAngle()
    }
    
    func toggleDrawMap() {
        MapMange.share.isDrawingMap.toggle()
    }
}

/// Slider type
public enum TripPicker: String, CaseIterable {
    case scaled = "scaled"
    case normal = "normal"
}

// MARK: - for voice by Text

import AVFoundation
public struct TextReaderView: View {
    @State public var textToRead: String = "This is an example text to be read out loud."
    @State public var textToReadVi: String = "Hôm nay thời tiết như thế nào?."
    public let speechSynthesizer = AVSpeechSynthesizer()
    
    public var body: some View {
        VStack {
            
            Button(action: {
                //readText(textToReadVi)
            }) {
                Text("Read Text")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - For Remove Data core gemini
public struct ButtonGenimiAddKeyView: View {
    @EnvironmentObject public var appVM: AppViewModel
    @Environment(\.managedObjectContext) public var context
    public var body: some View {
        Button(action: {
            
            let keyDB = GeminiAIManage.shared.getKey(from: context)
            print("getKey: ", keyDB)
            GeminiAIManage.keyString = ""
            let model = GeminiAIModel()
            try? model.removeAllData(context: context) { success in
                print("removeAllData success: ", success)
            }
            
            //appVM.showDialogView(with: "Enter Key", and: AnyView(GeminiAddKeyView()))
             
        }, label: {
            Image(systemName: IconDetailType.Star.rawValue)
        })
        
    }
}
