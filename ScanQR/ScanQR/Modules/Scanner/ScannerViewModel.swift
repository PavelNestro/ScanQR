import Foundation
import AVFoundation
import CoreData
import Combine
import SwiftUI

@MainActor
final class ScannerViewModel: ObservableObject {
    // MARK: - Published свойства
    @Published var isTorchOn = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var detectedURL: URL?
    @Published var showLinkBanner = false
    @Published var showSettingsAlert = false

    @Published var pendingCode: String?
    @Published var tempTitle: String = ""
    @Published var showNamePrompt = false
    
    let cameraService: CameraService
    
    // MARK: - Приватные свойства
    private var cancellables = Set<AnyCancellable>()
    private let repository: CodeRepository
    private let context: NSManagedObjectContext

    // MARK: - Публичные
    var session: AVCaptureSession { cameraService.session }

    // MARK: - Инициализация
    init(cameraService: CameraService, repository: CodeRepository) {
        self.cameraService = cameraService
        self.repository = repository
        self.context = repository.context
        bind()
    }

    // MARK: - Связывание Combine-потоков
    private func bind() {
        cameraService.codePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] code in
                guard let self = self else { return }
                self.pendingCode = code

                if let url = URL(string: code), code.lowercased().hasPrefix("http") {
                    self.tempTitle = "QR: \(url.host ?? "Ссылка")"
                    self.detectedURL = url
                    self.showLinkBanner = true
                } else if code.allSatisfy(\.isNumber) {
                    self.tempTitle = "Штрих-код \(code.prefix(8))"
                } else {
                    self.tempTitle = "Код"
                }

                self.showNamePrompt = true
            }
            .store(in: &cancellables)

        cameraService.$permissionDenied
            .receive(on: DispatchQueue.main)
            .sink { [weak self] denied in
                if denied { self?.showSettingsAlert = true }
            }
            .store(in: &cancellables)
    }

    // MARK: - Камера
    func requestCameraPermission() async {
        await cameraService.requestCameraPermission()
    }

    func startSession() {
        cameraService.startSession()
    }

    func stopSession() {
        cameraService.stopSession()
    }

    func toggleTorch() {
        cameraService.toggleTorch(isTorchOn: &isTorchOn)
    }

    // MARK: - Сохранение кода
    func savePendingCode() {
        guard let code = pendingCode else { return }
        let finalTitle = tempTitle.isEmpty ? "Неизвестно" : tempTitle
        repository.saveCode(code: code, title: finalTitle)
        showNamePrompt = false
        pendingCode = nil
        tempTitle = ""
    }
}
