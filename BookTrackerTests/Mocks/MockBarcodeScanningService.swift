import UIKit
@testable import BookTracker

@MainActor
final class MockBarcodeScanningService: BarcodeScanningService {
    var isSupported: Bool = true
    var authorizationStatusToReturn: BarcodeCameraAuthorizationStatus = .authorized
    var requestCameraAccessResult: Bool = true
    private var recognizeHandler: ((BarcodeScanOutcome) -> Void)?

    func authorizationStatus() -> BarcodeCameraAuthorizationStatus {
        authorizationStatusToReturn
    }

    func requestCameraAccess() async -> Bool {
        requestCameraAccessResult
    }

    func makeScannerViewController(onRecognize: @escaping (BarcodeScanOutcome) -> Void) -> UIViewController {
        recognizeHandler = onRecognize
        return UIViewController()
    }

    func simulateRecognition(_ outcome: BarcodeScanOutcome) {
        recognizeHandler?(outcome)
    }
}
