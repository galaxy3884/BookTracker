import UIKit

enum BarcodeCameraAuthorizationStatus {
    case authorized
    case notDetermined
    case denied
}

enum BarcodeScanOutcome {
    case isbn(String)
    case unsupportedCode
    case scanningUnavailable
}

@MainActor
protocol BarcodeScanningService: AnyObject {
    var isSupported: Bool { get }
    func authorizationStatus() -> BarcodeCameraAuthorizationStatus
    func requestCameraAccess() async -> Bool
    func makeScannerViewController(onRecognize: @escaping (BarcodeScanOutcome) -> Void) -> UIViewController
}
