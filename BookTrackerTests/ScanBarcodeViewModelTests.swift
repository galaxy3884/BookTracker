import Testing
@testable import BookTracker

@MainActor
@Suite("ScanBarcodeViewModel")
struct ScanBarcodeViewModelTests {
    @Test("camera unsupported shows the manual entry state")
    func cameraUnsupported() {
        let mock = MockBarcodeScanningService()
        mock.isSupported = false

        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        #expect(viewModel.state == .cameraUnavailable)
    }

    @Test("not-determined authorization asks the user for permission")
    func notDetermined() {
        let mock = MockBarcodeScanningService()
        mock.authorizationStatusToReturn = .notDetermined

        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        #expect(viewModel.state == .needsPermission)
    }

    @Test("denied authorization shows the permission-denied state")
    func denied() {
        let mock = MockBarcodeScanningService()
        mock.authorizationStatusToReturn = .denied

        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        #expect(viewModel.state == .permissionDenied)
    }

    @Test("authorized access shows the scanning state")
    func authorized() {
        let mock = MockBarcodeScanningService()
        mock.authorizationStatusToReturn = .authorized

        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        #expect(viewModel.state == .scanning)
    }

    @Test("requesting camera access moves to scanning when granted")
    func requestAccessGranted() async {
        let mock = MockBarcodeScanningService()
        mock.authorizationStatusToReturn = .notDetermined
        mock.requestCameraAccessResult = true
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        await viewModel.requestCameraAccess()

        #expect(viewModel.state == .scanning)
    }

    @Test("requesting camera access moves to permission denied when refused")
    func requestAccessDenied() async {
        let mock = MockBarcodeScanningService()
        mock.authorizationStatusToReturn = .notDetermined
        mock.requestCameraAccessResult = false
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }

        await viewModel.requestCameraAccess()

        #expect(viewModel.state == .permissionDenied)
    }

    @Test("recognizing a valid ISBN forwards it to the callback")
    func recognizingISBN() {
        let mock = MockBarcodeScanningService()
        var recognizedISBN: String?
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { isbn in
            recognizedISBN = isbn
        }
        _ = viewModel.makeScannerViewController()

        mock.simulateRecognition(.isbn("9781234567890"))

        #expect(recognizedISBN == "9781234567890")
    }

    @Test("recognizing an unsupported barcode sets a user-facing message instead of crashing")
    func recognizingUnsupportedCode() {
        let mock = MockBarcodeScanningService()
        var recognizedISBN: String?
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { isbn in
            recognizedISBN = isbn
        }
        _ = viewModel.makeScannerViewController()

        mock.simulateRecognition(.unsupportedCode)

        #expect(viewModel.unsupportedCodeMessage != nil)
        #expect(recognizedISBN == nil)
    }

    @Test("the scanner becoming unavailable mid-session falls back to manual entry")
    func scanningUnavailableFallback() {
        let mock = MockBarcodeScanningService()
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { _ in }
        _ = viewModel.makeScannerViewController()

        mock.simulateRecognition(.scanningUnavailable)

        #expect(viewModel.state == .cameraUnavailable)
    }

    @Test("submitting a blank manual ISBN does nothing")
    func submitBlankManualISBN() {
        let mock = MockBarcodeScanningService()
        var recognizedISBN: String?
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { isbn in
            recognizedISBN = isbn
        }
        viewModel.manualISBN = "   "

        viewModel.submitManualISBN()

        #expect(recognizedISBN == nil)
    }

    @Test("submitting a manual ISBN trims whitespace and forwards it")
    func submitManualISBN() {
        let mock = MockBarcodeScanningService()
        var recognizedISBN: String?
        let viewModel = ScanBarcodeViewModel(scanningService: mock) { isbn in
            recognizedISBN = isbn
        }
        viewModel.manualISBN = "  978123  "

        viewModel.submitManualISBN()

        #expect(recognizedISBN == "978123")
    }
}
