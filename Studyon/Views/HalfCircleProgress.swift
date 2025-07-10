//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  HalfCircleProgress.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/7/25.
//

import SwiftUI

struct HalfCircleProgress: View {
    var progress: CGFloat
    var totalSteps: Int
    var minValue: CGFloat
    var maxValue: CGFloat
    @State private var animatedProgress: CGFloat = 0
    var body: some View {
        ZStack {
            HalfCircleShape()
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.gray.opacity(0.3))
                .frame(width: 150, height: 75)
            
            HalfCircleShape().trim(from: 0.0, to: normalizedProgress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 121/255, green: 198/255, blue: 95/255), // Custom teal
                            Color(red: 86/255, green: 147/255, blue: 66/255)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 150, height: 75)
        }
        .onAppear {
            animatedProgress = 0
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = newValue
            }
        }
    }
    
    private var normalizedProgress: CGFloat {
        (animatedProgress - minValue) / (maxValue - minValue)
    }
    
    private var remainingSteps: Int {
        return max(0, totalSteps - Int(progress))
    }
}

#Preview {
    HalfCircleProgress(progress: 400, totalSteps: 500, minValue: 0, maxValue: 500)
}

struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        return path
    }
}
