//
//  HomeView.swift
//
//
//  Created by Krish Kapoor on 2/28/26.
//

import SwiftUI

public struct HomeView: View {
    @State private var drawProgress: CGFloat = 0.0
    @State private var fillOpacity: Double = 0.0
    @State private var showButton = false
    
    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 60) {
                    
                    let customFont = UIFont(name: "SignPainter", size: 110) ?? UIFont.systemFont(ofSize: 110, weight: .medium)
                    
                    ZStack {
                        // Solid fill
                        TextPath(text: "Authr", font: customFont)
                            .fill(Color.primary)
                            .opacity(fillOpacity)
                        
                        // Stroke outline
                        TextPath(text: "Authr", font: customFont)
                            .trim(from: 0.0, to: drawProgress)
                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                    .frame(width: 280, height: 120)
                    
                    NavigationLink(destination: SignatureView().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 12) {
                            Text("Personalize your Signature")
                                .font(.system(.headline, design: .serif))
                        }
                    }
                    .buttonStyle(SoftButton(bgColor: Color(UIColor.systemCyan), textColor: .white, showShadow: false))
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    private func startAnimations() {
        drawProgress = 0.0
        fillOpacity = 0.0
        showButton = false
        
        withAnimation(.easeInOut(duration: 2.5).delay(0.5)) {
            drawProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                fillOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showButton = true
            }
        }
    }
}
