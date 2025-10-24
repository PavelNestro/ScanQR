import Foundation
import CoreData
import AVFoundation
import SwiftUI

@MainActor
final class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isTorchOn = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var detectedURL: URL?
    @Published var showLinkBanner = false
    @Published var showSettingsAlert = false
    
    @Published var pendingCode: String?
    @Published var tempTitle: String = ""
    @Published var showNamePrompt = false

    let session = AVCaptureSession()
    private var isConfigured = false
    private var isProcessing = false
    
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
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
            if granted {
                startSession()
            } else {
                showSettingsAlert = true
            }
        case .denied, .restricted:
            showSettingsAlert = true
        @unknown default:
            showSettingsAlert = true
        }
    }

    private func showPermissionError() {
        errorMessage = "Доступ к камере запрещён. Разрешите использование в настройках."
        showError = true
    }

    func configureSession() {
        guard !isConfigured else { return }
        isConfigured = true

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            errorMessage = "Не удалось подключить камеру"
            showError = true
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
        }
    }

    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        try? device.lockForConfiguration()
        device.torchMode = isTorchOn ? .off : .on
        device.unlockForConfiguration()
        isTorchOn.toggle()
    }
    
    private func showDetectedLink(_ url: URL) {
        detectedURL = url
        showLinkBanner = true
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isProcessing else { return }
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }

        isProcessing = true
        print("Найден код: \(code)")

        DispatchQueue.main.async {
            self.pendingCode = code

            if let url = URL(string: code), code.lowercased().hasPrefix("http") {
                self.tempTitle = "QR: \(url.host ?? "Ссылка")"
            } else if code.allSatisfy(\.isNumber) {
                self.tempTitle = "Штрих-код \(code.prefix(8))"
            } else {
                self.tempTitle = "Код"
            }

            // Показываем Alert для ввода имени
            self.showNamePrompt = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isProcessing = false
        }
    }
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func savePendingCode() {
        guard let code = pendingCode else { return }
        let finalTitle = tempTitle.isEmpty ? "Неизвестно" : tempTitle
        saveToCoreData(code: code, title: finalTitle)
        showNamePrompt = false
        pendingCode = nil
        tempTitle = ""
    }

    private func saveToCoreData(code: String, title: String) {
        Task {
            let request = ScannedCode.fetchRequest()
            request.predicate = NSPredicate(format: "codeValue == %@", code)

            if let existing = try? context.fetch(request).first {
                print("Уже сохранено:", existing.codeValue ?? "")
                return
            }

            let newCode = ScannedCode(context: context)
            newCode.id = UUID()
            newCode.codeValue = code
            newCode.title = title
            newCode.scannedAt = Date()

            if code.allSatisfy(\.isNumber), code.count >= 8 {
                do {
                    let response = try await ProductRepository().fetchProduct(by: code)
                    if let product = response.product {
                        newCode.title = product.productName ?? title
                        newCode.brand = product.brands
                        newCode.ingredients = product.ingredientsText
                        newCode.nutriScore = product.nutriscoreGrade
                    }
                } catch {
                    print("Ошибка загрузки продукта:", error.localizedDescription)
                }
            }

            try? context.save()
            print("Сохранено в Core Data:", newCode.title ?? "-")
        }
    }

}
