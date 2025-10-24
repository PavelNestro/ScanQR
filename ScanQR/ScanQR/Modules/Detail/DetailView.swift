import SwiftUI
import CoreData

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel

    init(scanned: ScannedCode) {
        _viewModel = StateObject(
            wrappedValue: DetailViewModel(
                code: scanned,
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 16) {

                    // MARK: - Название
                    HStack {
                        if viewModel.isEditing {
                            TextField("Введите название", text: $viewModel.titleText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Сохранить") {
                                viewModel.saveChanges()
                            }
                        } else {
                            Text(viewModel.code.title ?? "Без названия")
                                .font(.title.bold())
                            Spacer()
                            Button {
                                withAnimation(.easeInOut) {
                                    viewModel.isEditing = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // MARK: - Содержимое кода
                    if let codeValue = viewModel.code.codeValue {
                        if let url = URL(string: codeValue),
                           UIApplication.shared.canOpenURL(url) {
                            Link("Открыть ссылку", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Содержимое: \(codeValue)")
                                .font(.body)
                        }
                    }

                    Divider()

                    // MARK: - Информация о продукте
                    if let brand = viewModel.code.brand, !brand.isEmpty {
                        Text("Бренд: \(brand)")
                    }

                    if let ingredients = viewModel.code.ingredients, !ingredients.isEmpty {
                        Text("Ингредиенты: \(ingredients)")
                    }

                    if let nutriScore = viewModel.code.nutriScore, !nutriScore.isEmpty {
                        Text("Nutri-Score: \(nutriScore.uppercased())")
                    }

                    // MARK: - Дата сканирования
                    Text("Дата сканирования: \(viewModel.code.scannedAt?.formatted() ?? "-")")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    // MARK: - Кнопка Поделиться
                    Button {
                        shareCode()
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .padding(.top, 12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground).opacity(0.9))
                        .shadow(radius: 8)
                )
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Детали кода")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Поделиться
    private func shareCode() {
        var shareText = "Сканированный код: \(viewModel.code.codeValue ?? "")"

        if let title = viewModel.code.title, !title.isEmpty {
            shareText += "\nНазвание: \(title)"
        }
        if let brand = viewModel.code.brand, !brand.isEmpty {
            shareText += "\nБренд: \(brand)"
        }
        if let ingredients = viewModel.code.ingredients, !ingredients.isEmpty {
            shareText += "\nИнгредиенты: \(ingredients)"
        }
        if let nutri = viewModel.code.nutriScore, !nutri.isEmpty {
            shareText += "\nNutri-Score: \(nutri.uppercased())"
        }

        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
