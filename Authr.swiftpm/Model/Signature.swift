//
//  Signature.swift
//
//  Created by Krish Kapoor on 2/11/26.
//
import SwiftUI

struct Stroke: Codable {
    var points: [CGPoint]
}

struct SignatureConfig {
    var scaleX: CGFloat = 1.0
    var scaleY: CGFloat = 1.0
    var shearX: CGFloat = 0.0
    var shearY: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var waveAmplitude: CGFloat = 0.0
    var waveFrequency: CGFloat = 0.005
    var jitterAmount: CGFloat = 0.0
}

struct Signature: Codable {
    var view: CGRect
    var strokes: [Stroke]
}
