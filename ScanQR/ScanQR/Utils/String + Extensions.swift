import Foundation

extension String {
    var isNumeric: Bool {
        !isEmpty && allSatisfy { $0.isNumber }
    }
}
