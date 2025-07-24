//
//  ContentView.swift
//  AR_Book
//
//  Created by Gurpreet on 22/07/25.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator

        // Load ARReferenceImages from asset catalog
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected AR Resources group in asset catalog.")
        }

        // Configure AR session for image detection and world tracking
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var audioPlayer: AVAudioPlayer?

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }
                placeModel(on: imageAnchor)
            }
        }

        private func placeModel(on imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }

            // Create an anchor entity at the image's position
            let anchorEntity = AnchorEntity(anchor: imageAnchor)

            // Load the USDZ model
            let modelEntity: ModelEntity
            do {
                let model = try ModelEntity.loadModel(named: "model.usdz")
                modelEntity = model
            } catch {
                print("Failed to load model: \(error)")
                return
            }

            // Optionally: scale/position the model as needed
            modelEntity.setPosition([0, 0, 0], relativeTo: anchorEntity)
            anchorEntity.addChild(modelEntity)

            // Add anchor to the scene
            arView.scene.addAnchor(anchorEntity)

            // Play sound
            playSound(named: "appear.mp3")
        }

        private func playSound(named name: String) {
            guard let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
    }
}
//
//#Preview {
//    ContentView()
//}
