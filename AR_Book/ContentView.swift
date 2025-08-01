//
//  ContentView.swift
//  AR_Book
//
//  Created by Gurpreet on 22/07/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSection: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .padding(.trailing, 150)
                
                // Overlay for better text readability
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("The AR World")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Bringing your world to life, one page at a time.\nExperience immersive AR magic through\n every image.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        NavigationButton(
                            title: "My Cars",
                            icon: "car.fill",
                            color: Color.orange
                        ) {
                            selectedSection = "cars"
                        }
                        
                        NavigationButton(
                            title: "My Recipy Book",
                            icon: "book.fill",
                            color: Color.green
                        ) {
                            selectedSection = "cookbook"
                        }
                        
                        NavigationButton(
                            title: "My Jungle",
                            icon: "leaf.fill",
                            color: Color.brown
                        ) {
                            selectedSection = "jungle"
                        }
                    }
                    .padding(.horizontal, 600)
                    
                    Spacer()
                    
                    // Footer
                    Text("Explore your AR world")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: Binding(
                get: { selectedSection != nil },
                set: { if !$0 { selectedSection = nil } }
            )) {
                if let section = selectedSection {
                    ARScanView(section: section)
                }
            }
        }
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(color.opacity(0.8))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ARScanView: View {
    let section: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = ModelLoader()
    
    var body: some View {
        ZStack {
            // AR View
            RealityViewContainer(modelLoader: loader)
                .edgesIgnoringSafeArea(.all)
            
            // Back button
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Loading overlay
            if loader.isLoading {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        LottieView(name: "5", loopMode: .loop)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Text("Loading your car !!")
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
            
            // Error overlay
            if let errorMessage = loader.errorMessage {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            
            // Instruction overlay
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


