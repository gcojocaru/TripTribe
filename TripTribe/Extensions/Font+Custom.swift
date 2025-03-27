//
//  Font+Custom.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

extension Font {
    static func jakartaSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("PlusJakartaSans-Bold", size: size)
        case .semibold:
            return .custom("PlusJakartaSans-SemiBold", size: size)
        case .medium:
            return .custom("PlusJakartaSans-Medium", size: size)
        case .regular:
            return .custom("PlusJakartaSans-Regular", size: size)
        case .light:
            return .custom("PlusJakartaSans-Light", size: size)
        default:
            return .custom("PlusJakartaSans-Regular", size: size)
        }
    }
}
