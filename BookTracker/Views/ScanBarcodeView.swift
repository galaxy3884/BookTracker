import SwiftUI

struct ScanBarcodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ScanBarcodeViewModel

    init(scanningService: BarcodeScanningService, onISBNRecognized: @escaping (String) -> Void) {
        _viewModel = State(initialValue: ScanBarcodeViewModel(scanningService: scanningService, onISBNRecognized: onISBNRecognized))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Strings.ScanBarcode.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Strings.Common.cancel) { dismiss() }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .checkingPermission:
            ProgressView()
        case .cameraUnavailable:
            manualEntryView
        case .needsPermission:
            permissionRequestView
        case .permissionDenied:
            permissionDeniedView
        case .scanning:
            scannerView
        }
    }

    private var scannerView: some View {
        ZStack(alignment: .bottom) {
            BarcodeScannerContainerView(makeViewController: viewModel.makeScannerViewController)
                .ignoresSafeArea()
            Text(Strings.ScanBarcode.scannerHint)
                .font(.subheadline)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                .padding()
        }
        .alert(Strings.ScanBarcode.unsupportedTitle, isPresented: unsupportedCodeBinding) {
            Button(Strings.ScanBarcode.retryAction, role: .cancel) {}
            Button(Strings.ScanBarcode.enterManuallyAction) { viewModel.state = .cameraUnavailable }
        } message: {
            Text(viewModel.unsupportedCodeMessage ?? "")
        }
    }

    private var permissionRequestView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(Strings.ScanBarcode.permissionNeededTitle)
                .font(.headline)
            Text(Strings.ScanBarcode.permissionNeededMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(Strings.ScanBarcode.allowCameraAction) {
                Task { await viewModel.requestCameraAccess() }
            }
            .buttonStyle(.borderedProminent)
            Button(Strings.ScanBarcode.enterISBNManuallyAction) {
                viewModel.state = .cameraUnavailable
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(Strings.ScanBarcode.permissionDeniedTitle)
                .font(.headline)
            Text(Strings.ScanBarcode.permissionDeniedMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(Strings.ScanBarcode.openSettingsAction) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            Button(Strings.ScanBarcode.enterISBNManuallyAction) {
                viewModel.state = .cameraUnavailable
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var manualEntryView: some View {
        Form {
            Section {
                TextField(Strings.ScanBarcode.isbnFieldPlaceholder, text: $viewModel.manualISBN)
                    .keyboardType(.numberPad)
            } header: {
                Text(Strings.ScanBarcode.manualEntryHeader)
            } footer: {
                Text(Strings.ScanBarcode.manualEntryFooter)
            }
            Section {
                Button(Strings.ScanBarcode.continueAction) {
                    viewModel.submitManualISBN()
                }
                .disabled(viewModel.manualISBN.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var unsupportedCodeBinding: Binding<Bool> {
        Binding(
            get: { viewModel.unsupportedCodeMessage != nil },
            set: { isPresented in if !isPresented { viewModel.unsupportedCodeMessage = nil } }
        )
    }
}
