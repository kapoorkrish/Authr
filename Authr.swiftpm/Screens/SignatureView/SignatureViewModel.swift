//
//  SignatureViewModel.swift
//
//
//  Created by Krish Kapoor on 2/11/26.
//

import SwiftUI
import CoreGraphics
import Vision

class SignatureViewModel: ObservableObject {
    @Published var showCamera: Bool = false
    @Published var showDemoPicker: Bool = false
    @Published var capturedImage: UIImage? = nil
    @Published var isProcessing: Bool = false
    @Published var showMissingAlert: Bool = false
    @Published var showPersonalitySheet: Bool = false
    @Published var showScanAlert: Bool = false
    
    @Published var baseSignature: Signature? = nil
    @Published var config = SignatureConfig()
    
    @Published var personality: Personality = .ISTJ {
        didSet {
            config = personalityPreset(for: personality)
        }
    }
    
    @Published var debugImage: UIImage? = nil
    
    init() {
        self.config = personalityPreset(for: self.personality)
    }
    
    // Apply transformations to signature
    var processedSignature: Signature? {
        guard let baseSignature else { return nil }
        
        var newSignature = baseSignature
        let currentConfig = self.config
        
        let centerX = baseSignature.view.midX
        let centerY = baseSignature.view.midY
        
        // Scale + Shear + Rotate
        let toOrigin = CGAffineTransform(translationX: -centerX, y: -centerY)
        let scale = CGAffineTransform(scaleX: currentConfig.scaleX, y: currentConfig.scaleY)
        let shear = CGAffineTransform(a: 1, b: currentConfig.shearY, c: currentConfig.shearX, d: 1, tx: 0, ty: 0)
        let rotation = CGAffineTransform(rotationAngle: currentConfig.rotationAngle)
        
        let personalityTransform = scale.concatenating(shear).concatenating(rotation)
        let fromOrigin = CGAffineTransform(translationX: centerX, y: centerY)
        let finalTransform = toOrigin.concatenating(personalityTransform).concatenating(fromOrigin)
        
        newSignature.strokes = baseSignature.strokes.map { stroke in
            Stroke(points: stroke.points.map { point in
                var p = point.applying(finalTransform)
                
                // Wave
                if currentConfig.waveAmplitude > 0 {
                    p.y += sin(p.x * currentConfig.waveFrequency) * currentConfig.waveAmplitude
                }
                
                // Jitter
                if currentConfig.jitterAmount > 0 {
                    let wobbleX = sin(p.y * 0.2) * cos(p.x * 0.15)
                    let wobbleY = cos(p.x * 0.2) * sin(p.y * 0.15)
                    
                    let paperTextureX = CGFloat.random(in: -0.15...0.15)
                    let paperTextureY = CGFloat.random(in: -0.15...0.15)
                    
                    p.x += (wobbleX + paperTextureX) * currentConfig.jitterAmount
                    p.y += (wobbleY + paperTextureY) * currentConfig.jitterAmount
                }
                
                return p
            })
        }
        
        return newSignature
    }
    
    // Personality Presets for all 16 MBTI
    private func personalityPreset(for type: Personality) -> SignatureConfig {
        switch type {
            // Sentinels
        case .ISTJ: return SignatureConfig(scaleX: 0.9, scaleY: 0.9)
        case .ISFJ: return SignatureConfig(scaleX: 0.95, scaleY: 0.95, shearX: 0.1, rotationAngle: -0.02, waveAmplitude: 3.0, waveFrequency: 0.01)
        case .ESTJ: return SignatureConfig(scaleX: 1.1, scaleY: 1.1, shearX: -0.1, jitterAmount: 0.1)
        case .ESFJ: return SignatureConfig(scaleX: 1.2, scaleY: 1.0, shearX: 0.15, rotationAngle: -0.02, waveAmplitude: 4.0, waveFrequency: 0.01)
            
            // Diplomats
        case .INFJ: return SignatureConfig(scaleX: 0.85, scaleY: 1.0, shearX: 0.2, rotationAngle: -0.05, waveAmplitude: 5.0, waveFrequency: 0.015)
        case .INFP: return SignatureConfig(scaleX: 1.1, scaleY: 1.0, shearX: 0.2, rotationAngle: -0.03, waveAmplitude: 9.0, waveFrequency: 0.02, jitterAmount: 0.2)
        case .ENFJ: return SignatureConfig(scaleX: 1.3, scaleY: 1.1, shearX: 0.25, rotationAngle: -0.05, waveAmplitude: 7.0, waveFrequency: 0.012)
        case .ENFP: return SignatureConfig(scaleX: 1.2, scaleY: 1.3, shearX: 0.2, rotationAngle: -0.1, waveAmplitude: 11.0, waveFrequency: 0.02, jitterAmount: 0.4)
            
            // Analysts
        case .INTJ: return SignatureConfig(scaleX: 0.8, scaleY: 0.75, shearX: 0.45, rotationAngle: 0.05)
        case .INTP: return SignatureConfig(scaleX: 0.9, scaleY: 1.1, shearX: 0.3, rotationAngle: 0.02, jitterAmount: 0.6)
        case .ENTJ: return SignatureConfig(scaleX: 1.15, scaleY: 1.6, shearX: -0.3, rotationAngle: -0.08, jitterAmount: 0.3)
        case .ENTP: return SignatureConfig(scaleX: 1.3, scaleY: 1.2, shearX: 0.5, rotationAngle: -0.08, waveAmplitude: 4.0, jitterAmount: 0.9)
            
            // Explorers
        case .ISTP: return SignatureConfig(scaleX: 1.0, scaleY: 0.85, shearX: 0.15)
        case .ISFP: return SignatureConfig(scaleX: 1.3, scaleY: 0.9, shearX: 0.1, rotationAngle: -0.05, waveAmplitude: 8.0, waveFrequency: 0.015)
        case .ESTP: return SignatureConfig(scaleX: 1.4, scaleY: 1.1, shearX: 0.7, rotationAngle: -0.12, jitterAmount: 0.8)
        case .ESFP: return SignatureConfig(scaleX: 1.5, scaleY: 1.2, shearX: 0.1, rotationAngle: -0.1, waveAmplitude: 12.0, waveFrequency: 0.018)
        }
    }
    
    // Convert signature image to vector
    func scanSignature(from image: UIImage) {
        let normalizedImage = fixOrientation(for: image)
        
        guard let cgImage = normalizedImage.cgImage else { return }
        
        let request = VNDetectContoursRequest()
        request.detectsDarkOnLight = true
        request.contrastPivot = 0.5
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return
        }
        
        guard let observation = request.results?.first else { return }
        
        var strokes: [Stroke] = []
        for i in 0..<observation.contourCount {
            guard let contour = try? observation.contour(at: i) else { continue }
            
            let xs = contour.normalizedPoints.map { CGFloat($0.x) }
            let ys = contour.normalizedPoints.map { CGFloat($0.y) }
            let width = (xs.max() ?? 0) - (xs.min() ?? 0)
            let height = (ys.max() ?? 0) - (ys.min() ?? 0)
            let area = width * height
            
            guard area < 0.95 && area > 0.0001 else { continue }
            
            let points = contour.normalizedPoints.map {
                CGPoint(x: CGFloat($0.x) * CGFloat(cgImage.width), y: CGFloat($0.y) * CGFloat(cgImage.height))
            }
            strokes.append(Stroke(points: points))
        }
        
        if !strokes.isEmpty {
            self.baseSignature = Signature(
                view: calculateBoundingBox(for: strokes),
                strokes: strokes
            )
        }
    }
    
    private func fixOrientation(for image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalized ?? image
    }
    
    private func calculateBoundingBox(for strokes: [Stroke]) -> CGRect {
        let allPoints = strokes.flatMap { $0.points }
        guard !allPoints.isEmpty else { return .zero }
        let xs = allPoints.map { $0.x }
        let ys = allPoints.map { $0.y }
        return CGRect(x: xs.min()!, y: ys.min()!, width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
    }
}
