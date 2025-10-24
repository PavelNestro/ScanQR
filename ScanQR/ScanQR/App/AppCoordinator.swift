//
//  AppCoordinator.swift
//  ScanQR
//
//  Created by Pavel Nesterenko on 23.10.25.
//
import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var selectedTab: Tab = .scanner
    @Published var selectedCode: ScannedCode? = nil
    @Published var path: NavigationPath = NavigationPath()

    enum Tab {
        case scanner
        case saved
    }

    func routeToDetails(code: ScannedCode) {
        selectedCode = code
        path.append(code)
    }

    func reset() {
        path = NavigationPath()
    }
}

