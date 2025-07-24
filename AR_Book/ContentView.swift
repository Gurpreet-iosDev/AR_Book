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
                LottieView(name: "2", loopMode: .loop)
                    .frame(width: 50, height: 50)
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
