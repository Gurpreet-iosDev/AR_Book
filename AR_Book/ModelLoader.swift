import Foundation
import FirebaseStorage
import Combine

class ModelLoader: ObservableObject {
    @Published var localURL: URL?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func downloadUSDZModel(named filename: String) {
        print("downloadUSDZModel called with filename: \(filename)")
        isLoading = true
        errorMessage = nil
        localURL = nil
        let storage = Storage.storage()
        let ref = storage.reference(withPath: filename)
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        print("Attempting to write to: \(tmpURL)")
        ref.write(toFile: tmpURL) { url, error in
            print("Download completion handler called")
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error downloading model: \(error.localizedDescription)")
                    self.errorMessage = "Error downloading model: \(error.localizedDescription)"
                    return
                }
                self.localURL = tmpURL
                print("Model downloaded to: \(tmpURL)")
            }
        }
    }
}
