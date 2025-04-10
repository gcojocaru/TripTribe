
// Components/AppStyles.swift
import SwiftUI

struct AppStyles {
    // Text Styles
    struct TextStyles {
        static func title(_ text: Text) -> some View {
            text
                .font(.jakartaSans(28, weight: .bold))
                .foregroundColor(.primary)
        }
        
        static func subtitle(_ text: Text) -> some View {
            text
                .font(.jakartaSans(18, weight: .semibold))
                .foregroundColor(.primary)
        }
        
        static func body(_ text: Text) -> some View {
            text
                .font(.jakartaSans(16, weight: .regular))
                .foregroundColor(.primary)
        }
        
        static func caption(_ text: Text) -> some View {
            text
                .font(.jakartaSans(14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
    
    // Container Styles
    struct Containers {
        static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            content()
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.Layout.cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        
        static func section<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.vertical, AppConstants.Layout.standardPadding / 2)
        }
    }
    
    // Input Styles
    struct InputStyles {
        static func textField<T: View>(_ field: T) -> some View {
            field
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppConstants.Layout.cornerRadius / 2)
        }
    }
}

// Extension to use styles more easily
extension View {
    func cardStyle() -> some View {
        AppStyles.Containers.card { self }
    }
    
    func sectionStyle() -> some View {
        AppStyles.Containers.section { self }
    }
    
    func textFieldStyle() -> some View {
        AppStyles.InputStyles.textField(self)
    }
}
