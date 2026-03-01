//
//  SignatureView.swift
//
//  Created by Krish Kapoor on 2/2/26.
//

import SwiftUI
import PhotosUI

public struct SignatureView: View {
    @StateObject private var viewModel = SignatureViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Canvas(viewModel: viewModel, isProcessing: viewModel.isProcessing)
                        .frame(height: 260)
                        .padding(.horizontal)
                    
                    PersonalitySelection(viewModel: viewModel, showSheet: $viewModel.showPersonalitySheet)
                    
                    AdvancedSettings(viewModel: viewModel)
                    
                    ActionButtons(
                        showCamera: $viewModel.showCamera,
                        showDemoPicker: $viewModel.showDemoPicker,
                        showScanAlert: $viewModel.showScanAlert
                    )
                    
                }
                .padding(.vertical, 20)
            }
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraScanner(selectedImage: $viewModel.capturedImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $viewModel.showDemoPicker) {
                DemoPickerSheet { selectedImage in
                    processImage(selectedImage)
                }
            }
            .sheet(isPresented: $viewModel.showPersonalitySheet) {
                PersonalitySheet(viewModel: viewModel, isPresented: $viewModel.showPersonalitySheet)
            }
            .onChange(of: viewModel.capturedImage) { newImage in
                if let image = newImage {
                    processImage(image)
                }
            }
            .alert("Images Missing", isPresented: $viewModel.showMissingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Could not find signature images.")
            }
            .alert("Scanning Tip", isPresented: $viewModel.showScanAlert) {
                Button("Got it") {
                    viewModel.showCamera = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Use black ink on white paper in a well-lit setting. Only the first image scanned will be used.")
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        viewModel.isProcessing = true
        Task {
            viewModel.scanSignature(from: image)
            await MainActor.run {
                viewModel.isProcessing = false
            }
        }
    }
}

// MARK: - Subviews
private struct Canvas: View {
    @ObservedObject var viewModel: SignatureViewModel
    var isProcessing: Bool
    
    @State private var drawingProgress: CGFloat = 0.0
    @State private var strokeOpacity: Double = 1.0
    @State private var finalFillOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            if isProcessing {
                ProgressView("Analyzing Handwriting...")
            }
            else if let signature = viewModel.processedSignature {
                GeometryReader { geometry in
                    let signaturePath = {
                        var path = Path()
                        let leftToRightStrokes = signature.strokes.sorted { strokeA, strokeB in
                            let minXa = strokeA.points.map(\.x).min() ?? 0
                            let minXb = strokeB.points.map(\.x).min() ?? 0
                            return minXa < minXb
                        }

                        for stroke in leftToRightStrokes {
                            var points = stroke.points
                            if let first = points.first, let last = points.last, first.x > last.x {
                                points.reverse()
                            }
                            guard let startPoint = points.first else { continue }
                            path.move(to: startPoint)
                            for pt in points.dropFirst() { path.addLine(to: pt) }
                        }

                        let bounds = path.boundingRect
                        guard bounds.width > 0 && bounds.height > 0 else { return path }
                        let padding: CGFloat = 40
                        let scale = min((geometry.size.width - padding) / bounds.width,
                                        (geometry.size.height - padding) / bounds.height)

                        let transform = CGAffineTransform(translationX: -bounds.midX, y: -bounds.midY)
                            .concatenating(CGAffineTransform(scaleX: scale, y: -scale))
                            .concatenating(CGAffineTransform(translationX: geometry.size.width / 2, y: geometry.size.height / 2))

                        return path.applying(transform)
                    }()
                    
                    ZStack {
                        signaturePath
                            .trim(from: 0, to: drawingProgress)
                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .opacity(strokeOpacity)
                        
                        signaturePath
                            .fill(Color.primary)
                            .opacity(finalFillOpacity)
                    }
                    .id(viewModel.personality)
                    .onAppear {
                        drawAnimation()
                    }
                    .onChange(of: viewModel.personality) { _ in
                        drawAnimation()
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "signature")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No Signature Scanned")
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func drawAnimation() {
        drawingProgress = 0.0
        strokeOpacity = 1.0
        finalFillOpacity = 0.0
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.1)) {
            drawingProgress = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.3).delay(1.7)) {
            finalFillOpacity = 1.0
            strokeOpacity = 0.0
        }
    }
}

private struct PersonalitySelection: View {
    @ObservedObject var viewModel: SignatureViewModel
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personality Type")
                .font(.system(.headline, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            Button(action: { showSheet = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(describing: viewModel.personality).uppercased())
                            .font(.system(.headline, design: .serif))
                        Text(viewModel.personality.traitDescription)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "pencil.line")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color(UIColor.systemCyan))
                }
            }
            .buttonStyle(SoftButton(bgColor: Color(UIColor.systemBackground), textColor: Color.primary))
            .padding(.horizontal)
        }
    }
}

private struct AdvancedSettings: View {
    @ObservedObject var viewModel: SignatureViewModel
    
    var body: some View {
        DisclosureGroup(
            content: {
                VStack(spacing: 15) {
                    HStack { Text("Width").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.scaleX, in: 0.5...2.5) }
                    HStack { Text("Height").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.scaleY, in: 0.5...2.5) }
                    HStack { Text("Shear").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.shearX, in: -1.0...1.0) }
                    HStack { Text("Rotation").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.rotationAngle, in: -0.5...0.5) }
                    HStack { Text("Wave Amp").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.waveAmplitude, in: 0.0...25.0) }
                    HStack { Text("Jitter").frame(width: 80, alignment: .leading); Slider(value: $viewModel.config.jitterAmount, in: 0.0...3.0) }
                }
                .font(.caption)
                .padding(.top, 10)
            },
            label: {
                Text("Advanced Settings")
                    .font(.system(.headline, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        )
        .padding(.horizontal, 24)
    }
}

private struct ActionButtons: View {
    @Binding var showCamera: Bool
    @Binding var showDemoPicker: Bool
    @Binding var showScanAlert: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Scan button
            Button(action: {
                showScanAlert = true
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "camera.viewfinder")
                        .font(.body)
                    Text("Scan Signature")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SoftButton(bgColor: Color(UIColor.systemCyan), textColor: .white))
            
            // Demo button
            Button(action: { showDemoPicker = true }) {
                VStack(spacing: 6) {
                    Image(systemName: "testtube.2")
                        .font(.body)
                    Text("Try Demo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SoftButton(bgColor: Color(UIColor.systemBackground), textColor: Color(UIColor.systemCyan)))
        }
        .padding(.horizontal)
    }
}
