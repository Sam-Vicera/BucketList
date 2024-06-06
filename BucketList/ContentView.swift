//
//  ContentView.swift
//  BucketList
//
//  Created by Samuel Hernandez Vicera on 4/15/24.
//
import LocalAuthentication
import MapKit
import SwiftUI


struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: 3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    )
    
    @State private var viewModel = ViewModel()
    @State private var mapType = false
    @State private var authenticationFailed = false
    
    var body: some View {
        if viewModel.isUnlocked {
            NavigationStack{
                
                
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) {location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {                         viewModel.update(location: $0)
                        }
                    }
                    .mapStyle(mapType == false ? .standard : .hybrid)
                }
                .toolbar {
                    ToolbarItem {
                        Toggle(isOn: $mapType, label: {
                            if mapType == false {
                                Text("Standard")
                            }
                            else {
                                Text("Hybrid")
                            }
                        })
                        .toggleStyle(.switch)
                        .padding()
                        
                    }
                }
            }
            .alert(viewModel.errorMessage, isPresented: $viewModel.errorPopUp) {
                Button("Try again", action: viewModel.authenticate)
            }

        }
            
        else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
                    
    }
}

#Preview {
    ContentView()
}
