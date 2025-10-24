import SwiftUI
import CoreData

struct ScannedListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScannedCode.scannedAt, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<ScannedCode>

    var body: some View {
        List {
            ForEach(items) { item in
                Button {
                    coordinator.routeToDetails(code: item)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title ?? "Без названия")
                            .font(.headline)
                        Text(item.codeValue ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if let date = item.scannedAt {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Сохранённые коды")
    }
}
