import Foundation
import UIKit

enum ScanBarcodeState {
    case checkingPermission
    case cameraUnavailable
    case needsPermission
    case permissionDenied
    case scanning
}

@MainActor
@Observable
final class ScanBarcodeViewModel {
    private let scanningService: BarcodeScanningService
    private let onISBNRecognized: (String) -> Void

    var state: ScanBarcodeState
    var manualISBN: String = ""
    var unsupportedCodeMessage: String?

    init(scanningService: BarcodeScanningService, onISBNRecognized: @escaping (String) -> Void) {
        self.scanningService = scanningService
        self.onISBNRecognized = onISBNRecognized
        self.state = .checkingPermission
        evaluateState()
    }

    func evaluateState() {
        guard scanningService.isSupported else {
            state = .cameraUnavailable
            return
        }
        switch scanningService.authorizationStatus() {
        case .authorized:
            state = .scanning
        case .notDetermined:
            state = .needsPermission
        case .denied:
            state = .permissionDenied
        }
    }

    func requestCameraAccess() async {
        let granted = await scanningService.requestCameraAccess()
        state = granted ? .scanning : .permissionDenied
    }

    func submitManualISBN() {
        let trimmed = manualISBN.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onISBNRecognized(trimmed)
    }

    func makeScannerViewController() -> UIViewController {
        scanningService.makeScannerViewController { [weak self] outcome in
            self?.handle(outcome)
        }
    }

    private func handle(_ outcome: BarcodeScanOutcome) {
        switch outcome {
        case .isbn(let isbn):
            onISBNRecognized(isbn)
        case .unsupportedCode:
            unsupportedCodeMessage = Strings.ScanBarcode.unsupportedCodeMessage
        case .scanningUnavailable:
            state = .cameraUnavailable
        }
    }
}
