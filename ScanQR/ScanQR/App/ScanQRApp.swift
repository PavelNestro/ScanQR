
import SwiftUI

@main
struct ScanQRApp: App {
    private var persistence = PersistenceController.shared
    @StateObject private var coordinator = AppCoordinator()

    init() {
        setupTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(coordinator)
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
