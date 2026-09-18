import SwiftUI

struct BarcodeScannerContainerView: UIViewControllerRepresentable {
    let makeViewController: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        makeViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
