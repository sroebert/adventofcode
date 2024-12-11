import Foundation

extension FixedWidthInteger {
    var numberOfDigits: Double {
        floor(log10(Double(self))) + 1
    }
}
