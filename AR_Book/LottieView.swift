import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let speed: CGFloat

    init(name: String, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: container.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: container.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No update needed
    }
}
