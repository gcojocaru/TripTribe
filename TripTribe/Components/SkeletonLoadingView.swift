//
//  SkeletonLoadingView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import SwiftUI

struct SkeletonLoadingView: View {
    let isLoading: Bool
    let content: AnyView
    
    init<Content: View>(isLoading: Bool, @ViewBuilder content: () -> Content) {
        self.isLoading = isLoading
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                VStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 80)
                            .shimmer()
                    }
                }
                .padding()
            } else {
                content
            }
        }
    }
}

// Extension to add shimmer effect
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.5),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + self.phase * (geo.size.width * 3))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    self.phase = 1
                }
            }
    }
}
