import AVFoundation
import Combine

final class CameraService: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    let codePublisher = PassthroughSubject<String, Never>()
    @Published var permissionDenied = false

    private var isConfigured = false

    override init() {
        super.init()
        configureSession()
    }

    func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startSession()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            granted ? startSession() : (permissionDenied = true)
        default:
            permissionDenied = true
        }
    }

    private func configureSession() {
        guard !isConfigured else { return }
        isConfigured = true

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
        }
    }

    func startSession() {
        if !session.isRunning { session.startRunning() }
    }

    func stopSession() {
        if session.isRunning { session.stopRunning() }
    }

    func toggleTorch(isTorchOn: inout Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isTorchOn ? .off : .on
            isTorchOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Ошибка при переключении фонарика: \(error)")
        }
    }

    // MARK: - Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }

        codePublisher.send(code)
    }
}
