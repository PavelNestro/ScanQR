import SwiftUI
import AVFoundation

struct ScannerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: ScannerViewModel

    init() {
        let cameraService = CameraService()
        let repository = CodeRepository(context: PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(
            wrappedValue: ScannerViewModel(
                cameraService: cameraService,
                repository: repository
            )
        )
    }

    var body: some View {
        ZStack {
            // Камера
            CameraPreviewView(session: viewModel.cameraService.session)
                .ignoresSafeArea()

            // Зелёная рамка
            Rectangle()
                .strokeBorder(Color.green, lineWidth: 3)
                .frame(width: 250, height: 250)

            // Фонарик
            VStack {
                HStack {
                    Spacer()
                    Button(action: { viewModel.toggleTorch() }) {
                        Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // Баннер с QR-ссылкой
            if viewModel.showLinkBanner, let url = viewModel.detectedURL {
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Обнаружена ссылка")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        Text(url.absoluteString)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Button {
                            UIApplication.shared.open(url)
                            viewModel.showLinkBanner = false
                        } label: {
                            Label("Открыть", systemImage: "safari")
                                .font(.callout)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showLinkBanner)
            }
        }

        // MARK: - Alerts
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Нет доступа к камере", isPresented: $viewModel.showSettingsAlert) {
            Button("Открыть настройки") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Чтобы использовать сканер, разрешите доступ к камере в настройках.")
        }
        .alert("Сохранить код", isPresented: $viewModel.showNamePrompt) {
            TextField("Введите название", text: $viewModel.tempTitle)
            Button("Сохранить") {
                viewModel.savePendingCode()
            }
            Button("Отмена", role: .cancel) {
                viewModel.pendingCode = nil
            }
        } message: {
            Text("Введите название для сохранённого кода")
        }

        // MARK: - Жизненный цикл
        .task {
            await viewModel.requestCameraPermission()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

