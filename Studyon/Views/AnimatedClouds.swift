//
//  AnimatedClouds.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/3/25.
//

import Foundation
import SwiftUI

struct AnimatedCloudsView: View {
    struct Cloud: Identifiable {
        let id = UUID()
        let emoji: String
        let size: CGFloat
        let yFraction: CGFloat
        let speed: Double // seconds for one full travel
        let startOnLeft: Bool
    }
    
    let clouds: [Cloud] = [
        Cloud(emoji: "☁️", size: 80, yFraction: 0.14, speed: 32, startOnLeft: true),
        Cloud(emoji: "☁️", size: 110, yFraction: 0.33, speed: 44, startOnLeft: false),
        Cloud(emoji: "☁️", size: 65, yFraction: 0.57, speed: 26, startOnLeft: true),
        Cloud(emoji: "☁️", size: 95, yFraction: 0.82, speed: 38, startOnLeft: false)
    ]
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(clouds) { cloud in
                        let period = cloud.speed
                        let phase = (now.truncatingRemainder(dividingBy: period)) / period
                        let lerp = cloud.startOnLeft ? phase : (1 - phase)
                        let startX = -cloud.size
                        let endX = width + cloud.size
                        let x = startX + (endX - startX) * lerp
                        // Opacity: fade in/out over first and last 12.5% of travel
                        let fadePct = 0.125
                        let inFade = lerp < fadePct ? lerp / fadePct : (lerp > 1 - fadePct ? (1 - lerp) / fadePct : 1)
                        let opacity = max(0, min(1, inFade))
                        Text(cloud.emoji)
                            .font(.system(size: cloud.size))
                            .position(x: x, y: cloud.yFraction * geo.size.height)
                            .opacity(opacity)
                    }
                }
            }
        }
    }
}

#Preview(body: {
    AnimatedCloudsView()
})
