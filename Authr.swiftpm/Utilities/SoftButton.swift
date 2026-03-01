//
//  ButtonStyle.swift
//  
//
//  Created by Krish Kapoor on 2/28/26.
//
import SwiftUI

public struct SoftButton: ButtonStyle {
    var bgColor: Color
    var textColor: Color
    var showShadow: Bool = true
    
    public init(bgColor: Color, textColor: Color, showShadow: Bool = true) {
        self.bgColor = bgColor
        self.textColor = textColor
        self.showShadow = showShadow
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(bgColor)
                    .shadow(
                        color: Color.black.opacity(showShadow ? 0.15 : 0),
                        radius: showShadow ? 8 : 0,
                        x: 0,
                        y: showShadow ? 4 : 0
                    )
            )
            .foregroundColor(textColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
