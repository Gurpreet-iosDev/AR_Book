import SwiftUI
import RealityKit
import ARKit
import Combine

struct RealityViewContainer: UIViewRepresentable {
    @ObservedObject var modelLoader: ModelLoader
    
    func makeCoordinator() -> Coordinator {
        Coordinator(modelLoader: modelLoader)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView

        // Load ARReferenceImages from asset catalog
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected AR Resources group in asset catalog.")
        }

        // Configure AR session for image detection and world tracking
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject, ARSessionDelegate {
        var cancellables = Set<AnyCancellable>()
        let modelLoader: ModelLoader
        weak var arView: ARView?
        let imageToModelMap: [String: String] = [
            "MercedesImage": "1954_Mercedes-Benz_300SL_Gullwing.usdz",
            "FerrariImage": "Ferrari_P45_Pininfarina__www.vecarz.usdz",
            "RenaultImage": "Renault_RE40__www.vecarz.usdz",
            "DodgeImage": "1969_Dodge_Charger_RT.usdz",
            "RaptorImage": "Ford_Raptor.usdz"
        ]
        private var lastAnchorEntity: AnchorEntity?

        init(modelLoader: ModelLoader) {
            self.modelLoader = modelLoader
            super.init()
            // Observe when the model is loaded
            modelLoader.$localURL
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    print("modelLoader.$localURL fired with url: \(String(describing: url))")
                    guard let self = self, let url = url, let arView = self.arView, let anchorEntity = self.lastAnchorEntity else {
                        print("Missing self, url, arView, or anchorEntity in modelLoader.$localURL sink")
                        return
                    }
                    print("Current anchor count in scene: \(arView.scene.anchors.count)")
                    print("Found anchor entity for model placement. Starting model load for url: \(url)")
                    ModelEntity.loadModelAsync(contentsOf: url)
                        .sink(receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                print("Error loading model: \(error)")
                            } else {
                                print("Model loaded successfully!")
                            }
                        }, receiveValue: { modelEntity in
                            print("Adding model entity to anchor, elevating by 20cm. ModelEntity: \(modelEntity)")
                            modelEntity.setScale(SIMD3<Float>(0.0005, 0.0005, 0.0005), relativeTo: nil) // Scale down to 5%
                            modelEntity.position = SIMD3<Float>(0, 0.02, 0)
                            anchorEntity.addChild(modelEntity)
                            print("Model entity added to anchor.")
                        })
                        .store(in: &self.cancellables)
                }
                .store(in: &cancellables)
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor,
                      let imageName = imageAnchor.referenceImage.name else { continue }
                print("Detected image: \(imageName)")
                if let modelName = imageToModelMap[imageName], let arView = arView {
                    print("Preparing to download model: \(modelName)")
                    // Create an anchor entity for the detected image using .image initializer
                    let anchorEntity = AnchorEntity(.image(group: "AR Resources", name: imageName))
                    arView.scene.addAnchor(anchorEntity)
                    lastAnchorEntity = anchorEntity
                    print("Anchor entity added: \(anchorEntity)")
                    // Download the model (when ready, it will be added above)
                    DispatchQueue.main.async {
                        self.modelLoader.downloadUSDZModel(named: modelName)
                    }
                } else {
                    print("No model mapping found for image: \(imageName)")
                }
            }
        }
    }
} 
