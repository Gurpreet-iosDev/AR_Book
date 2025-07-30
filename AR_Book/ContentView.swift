//
//  ContentView.swift
//  AR_Book
//
//  Created by Gurpreet on 22/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loader = ModelLoader()

    var body: some View {
        ZStack {
            // Always show ARView so image detection works
            RealityViewContainer(modelLoader: loader)
                .edgesIgnoringSafeArea(.all)

            // Overlay Lottie animation when loading
            if loader.isLoading {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        LottieView(name: "2", loopMode: .loop)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Text("Loading model...")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                    )
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }

            // Overlay error message if needed
            if let errorMessage = loader.errorMessage {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }

            // Optional: Overlay instruction if nothing is loaded yet
            if !loader.isLoading && loader.errorMessage == nil && loader.localURL == nil {
                VStack {
                    Spacer()
                    Text("Point your camera at an image to load a model")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
