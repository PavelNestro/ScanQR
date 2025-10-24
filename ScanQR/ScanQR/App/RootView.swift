import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView(selection: $coordinator.selectedTab) {
                ScannerView()
                    .tabItem {
                        Label("Сканер", systemImage: "barcode.viewfinder")
                    }
                    .tag(AppCoordinator.Tab.scanner)
                    .environment(\.managedObjectContext, context)
                ScannedListView()
                    .tabItem {
                        Label("Сохранённые", systemImage: "tray.full")
                    }
                    .tag(AppCoordinator.Tab.saved)
                    .environment(\.managedObjectContext, context)
            }
            .navigationDestination(for: ScannedCode.self) { code in
                DetailView(scanned: code)
            }
        }
    }
}


