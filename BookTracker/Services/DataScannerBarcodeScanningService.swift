import AVFoundation
import UIKit
import VisionKit
import Vision

final class DataScannerBarcodeScanningService: BarcodeScanningService {
    static let bookSymbologies: [VNBarcodeSymbology] = [.ean13, .upce]

    var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    func authorizationStatus() -> BarcodeCameraAuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            .authorized
        case .notDetermined:
            .notDetermined
        case .denied, .restricted:
            .denied
        @unknown default:
            .denied
        }
    }

    func requestCameraAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func makeScannerViewController(onRecognize: @escaping (BarcodeScanOutcome) -> Void) -> UIViewController {
        BarcodeScannerHostViewController(onRecognize: onRecognize)
    }
}

private final class BarcodeScannerHostViewController: UIViewController, DataScannerViewControllerDelegate {
    private let onRecognize: (BarcodeScanOutcome) -> Void
    private let scannerViewController: DataScannerViewController

    init(onRecognize: @escaping (BarcodeScanOutcome) -> Void) {
        self.onRecognize = onRecognize
        self.scannerViewController = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scannerViewController.delegate = self
        addChild(scannerViewController)
        scannerViewController.view.frame = view.bounds
        scannerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scannerViewController.view)
        scannerViewController.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            try scannerViewController.startScanning()
        } catch {
            onRecognize(.scanningUnavailable)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerViewController.stopScanning()
    }

    func dataScanner(
        _ dataScanner: DataScannerViewController,
        didAdd addedItems: [RecognizedItem],
        allItems: [RecognizedItem]
    ) {
        guard let item = addedItems.first else { return }
        handle(item)
    }

    private func handle(_ item: RecognizedItem) {
        guard case let .barcode(barcode) = item else { return }
        guard let payload = barcode.payloadStringValue else { return }
        guard DataScannerBarcodeScanningService.bookSymbologies.contains(barcode.observation.symbology) else {
            onRecognize(.unsupportedCode)
            return
        }
        onRecognize(.isbn(payload))
    }
}
