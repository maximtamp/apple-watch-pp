//
//  RaceCar.swift
//  car-step
//
//  Created by Maxim Tampere on 26/01/2026.
//

import SwiftUI

struct RaceCar: View {
    let color: Color
    let duration: Double
    let run: Double

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 60, height: 60)
            .cornerRadius(30)
            .keyframeAnimator(
                initialValue: AnimationValues(time: 0),
                repeating: true
            ) { content, value in
                let easedTime = 1 - cos(value.time * .pi / 2)
                content
                    .modifier(TranslateAlongPath(
                        path: roundedRectangleRacePath(),
                        maxTime: easedTime
                    ))
                    .frame(width: 200, height: 400)
            } keyframes: { _ in
                KeyframeTrack(\.time) {
                    CubicKeyframe(run, duration: duration)
                }
            }
    }
    
    struct TranslateAlongPath: ViewModifier {
        let path: Path
        let maxTime: CGFloat

        func body(content: Content) -> some View {
            let trimmed = path.trimmedPath(from: 0, to: maxTime)
            let start = CGPoint(x: 200, y: 200)
            let point = trimmed.currentPoint ?? start

            return content.position(point)
        }
    }
    
    struct AnimationValues {
        var time: CGFloat
    }

    
    func roundedRectangleRacePath(width: CGFloat = 200, height: CGFloat = 400, cornerRadius: CGFloat = 100) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: width, y: height / 2))
        
        path.addLine(to: CGPoint(x: width, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0),
                          control: CGPoint(x: width, y: 0))
        
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius),
                          control: CGPoint(x: 0, y: 0))
        
        path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: height),
                          control: CGPoint(x: 0, y: height))
        
        path.addLine(to: CGPoint(x: width - cornerRadius, y: height))
        path.addQuadCurve(to: CGPoint(x: width, y: height - cornerRadius),
                          control: CGPoint(x: width, y: height))
        
        path.addLine(to: CGPoint(x: width, y: height / 4))
        
        return path
    }

}
