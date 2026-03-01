//
//  Path.swift
//  
//
//  Created by Krish Kapoor on 2/28/26.
//
import SwiftUI

public struct TextPath: Shape {
    public var text: String
    public var font: UIFont

    public func path(in rect: CGRect) -> Path {
        let rawPath = Path(string: text, font: font)
        let bounds = rawPath.boundingRect
        
        let scale = min(rect.width / bounds.width, rect.height / bounds.height)
        let transform = CGAffineTransform(scaleX: scale, y: -scale)
            .translatedBy(x: (rect.width/scale - bounds.width)/2 - bounds.minX,
                          y: -(rect.height/scale + bounds.height)/2 - bounds.minY)
        
        return rawPath.applying(transform)
    }
}

extension Path {
    init(string: String, font: UIFont) {
        self.init()
        let attrString = NSAttributedString(string: string, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(attrString)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        
        for run in runs {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let runFont = attributes[kCTFontAttributeName as NSString] as! CTFont
            for i in 0..<CTRunGetGlyphCount(run) {
                var glyph = CGGlyph(), position = CGPoint.zero
                CTRunGetGlyphs(run, CFRangeMake(i, 1), &glyph)
                CTRunGetPositions(run, CFRangeMake(i, 1), &position)
                if let letterPath = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                    self.addPath(Path(letterPath), transform: CGAffineTransform(translationX: position.x, y: position.y))
                }
            }
        }
    }
}

// Bezier Math
func quadBezier(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint) -> CGPoint {
    let x = (1-t)*(1-t)*p0.x + 2*(1-t)*t*p1.x + t*t*p2.x
    let y = (1-t)*(1-t)*p0.y + 2*(1-t)*t*p1.y + t*t*p2.y
    return CGPoint(x: x, y: y)
}

func cubicBezier(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
    let x = pow(1-t, 3)*p0.x + 3*pow(1-t, 2)*t*p1.x + 3*(1-t)*pow(t, 2)*p2.x + pow(t, 3)*p3.x
    let y = pow(1-t, 3)*p0.y + 3*pow(1-t, 2)*t*p1.y + 3*(1-t)*pow(t, 2)*p2.y + pow(t, 3)*p3.y
    return CGPoint(x: x, y: y)
}
