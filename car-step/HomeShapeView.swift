//
//  HomeShapeView.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI

struct PartSVGo: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.31944*width, y: 0.79759*height))
        path.addLine(to: CGPoint(x: 0.49079*width, y: 0.61982*height))
        path.addLine(to: CGPoint(x: 0.67056*width, y: 0.79759*height))
        path.addLine(to: CGPoint(x: 0.74079*width, y: 0.74482*height))
        path.addLine(to: CGPoint(x: 0.62843*width, y: 0.54204*height))
        path.addLine(to: CGPoint(x: 0.83629*width, y: 0.43093*height))
        path.addLine(to: CGPoint(x: 0.81382*width, y: 0.34759*height))
        path.addLine(to: CGPoint(x: 0.58348*width, y: 0.38926*height))
        path.addLine(to: CGPoint(x: 0.53573*width, y: 0.14759*height))
        path.addLine(to: CGPoint(x: 0.45146*width, y: 0.14759*height))
        path.addLine(to: CGPoint(x: 0.41494*width, y: 0.38093*height))
        path.addLine(to: CGPoint(x: 0.1818*width, y: 0.34204*height))
        path.addLine(to: CGPoint(x: 0.1509*width, y: 0.42537*height))
        path.addLine(to: CGPoint(x: 0.36719*width, y: 0.54204*height))
        path.addLine(to: CGPoint(x: 0.25764*width, y: 0.74482*height))
        path.addCurve(to: CGPoint(x: 0.49079*width, y: 0.14759*height), control1: CGPoint(x: -0.00921*width, y: 0.44481*height), control2: CGPoint(x: 0.25226*width, y: 0.13709*height))
        path.addCurve(to: CGPoint(x: 0.70752*width, y: 0.76982*height), control1: CGPoint(x: 0.91624*width, y: 0.16633*height), control2: CGPoint(x: 0.90611*width, y: 0.61982*height))
        path.addCurve(to: CGPoint(x: 0.26045*width, y: 0.75037*height), control1: CGPoint(x: 0.5993*width, y: 0.85156*height), control2: CGPoint(x: 0.41908*width, y: 0.90939*height))
        path.addLine(to: CGPoint(x: 0.16775*width, y: 0.85871*height))
        path.addCurve(to: CGPoint(x: 0.81382*width, y: 0.1087*height), control1: CGPoint(x: 0.58348*width, y: 1.28371*height), control2: CGPoint(x: 1.34472*width, y: 0.61982*height))
        path.addCurve(to: CGPoint(x: 0.16213*width, y: 0.85593*height), control1: CGPoint(x: 0.46769*width, y: -0.2163*height), control2: CGPoint(x: -0.33786*width, y: 0.25593*height))
        return path
    }
}

struct HomeShapeView: View {
    let part: Part
    var body: some View {
        VStack {
            Spacer()
            part.getPartShape(neededPart: part.type, progress: part.progressPrecent)
            Spacer()
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 300, height: 300)
    }
}

#Preview {
    let dummyPart = Part(name: "Sparky", type: "Wheel", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now)
    HomeShapeView(part: dummyPart)
}
