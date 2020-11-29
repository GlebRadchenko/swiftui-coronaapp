//
//  FlowerLoadingView.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import SwiftUI

struct LoadingSpinner: View {
    @State private var progress: Double = 0
    @State private var rotate = false

    var body: some View {
        GeometryReader { proxy in
            RingShape(progress: progress)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: proxy.size.width / 10,
                        lineCap: .round
                    )
                )
                .fill(
                    AngularGradient(
                        gradient: Gradient(
                            colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink]
                        ),
                        center: UnitPoint(x: 0.5, y: 0.5),
                        startAngle: .radians(0),
                        endAngle: .radians(2 * .pi)
                    )
                )
                .rotationEffect(Angle(degrees: rotate ? 360 : 0))
        }
        .onAppear() {
            withAnimation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false)
            ) {
                progress = 1
                rotate = true
            }
        }
    }
}

struct RingShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let radius = min(rect.width, rect.height) / 2

            let start: Angle

            if progress <= 0.5 {
                start = .radians(0)
            } else {
                let tailProgress = (progress - 0.5) / 0.5
                start = .radians(2 * .pi * tailProgress)
            }

            path.addArc(
                center: .init(x: rect.midX, y: rect.midY),
                radius: radius,
                startAngle: start,
                endAngle: .radians(2 * .pi * progress),
                clockwise: false
            )
        }
    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinner()
            .frame(width: 220, height: 220, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
