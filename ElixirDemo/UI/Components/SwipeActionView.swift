//
//  SwipeActionView.swift
//  Elixir: Daily Ritual
//
//  A wrapper view that adds swipe-to-delete functionality
//

import SwiftUI

struct SwipeActionView<Content: View>: View {
    let content: Content
    let onDelete: () -> Void
    let cornerRadius: CGFloat
    
    @State private var offset: CGFloat = 0
    @State private var isVisible: Bool = false
    @Environment(ThemeManager.self) private var themeManager
    
    // Config
    private let buttonWidth: CGFloat = 80
    
    init(cornerRadius: CGFloat = 16, onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.onDelete = onDelete
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background / Delete Button
            if isVisible {
                Button {
                    withAnimation {
                        offset = 0
                        isVisible = false
                    }
                    onDelete()
                } label: {
                    ZStack {
                        Color(hex: "EF4444") // Red
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: buttonWidth)
                .cornerRadius(cornerRadius, corners: [.topRight, .bottomRight])
                .cornerRadius(4, corners: [.topLeft, .bottomLeft]) // Mild curve on inner side
                .padding(.leading, 100) // Extends color far left if dragged deeply
            }
            
            // Content
            content
                .background(Color.black.opacity(0.001)) // Hit test
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow left swipe
                            let translation = value.translation.width
                            if translation < 0 {
                                // Resistance effect
                                offset = translation
                            } else if offset < 0 {
                                // If already open, allow closing
                                offset = translation - buttonWidth
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                if value.translation.width < -buttonWidth / 2 {
                                    offset = -buttonWidth
                                    isVisible = true
                                } else {
                                    offset = 0
                                    isVisible = false
                                }
                            }
                        }
                )
        }
        .onAppear {
            // Ensure invisible initially
            isVisible = false
        }
    }
}

// Extension to help with specific corner radii if needed, or just rely on clipping.
// For simplicity, we might just clip the whole thing to the content's shape if we can.
// But passed cornerRadius is safer.
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
