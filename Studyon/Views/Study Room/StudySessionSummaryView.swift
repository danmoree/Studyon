//
//  Created by Daniel Moreno on 2026
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudySessionSummaryView.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/1/26.
//

import SwiftUI

struct StudySessionSummaryView: View {
    let studyTime: TimeInterval // Total study time in seconds
    let xpGained: Int
    let oldXP: Int // XP before session
    let newXP: Int // XP after session
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showXPGain = false
    @State private var showProgressBar = false
    @State private var animateProgress = false
    @State private var showLevelUp = false
    @Environment(\.colorScheme) var colorScheme

    private let levelSystem = LevelSystem.shared

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)

                    Text("Session Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontWidth(.expanded)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                }
                .padding(.top, 32)

                // Study Time
                VStack(spacing: 12) {
                    Text("Time Studied")
                        .font(.headline)
                        .fontWidth(.expanded)
                        .foregroundStyle(.secondary)

                    Text(formatTime(studyTime))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .fontWidth(.expanded)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)

                Divider()
                    .padding(.horizontal, 40)

                // XP Gained
                VStack(spacing: 12) {
                    Text("XP Gained")
                        .font(.headline)
                        .fontWidth(.expanded)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)

                        Text("+\(xpGained)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .fontWidth(.expanded)
                            .foregroundColor(.yellow)
                    }
                    .scaleEffect(showXPGain ? 1.2 : 0.8)
                    .opacity(showXPGain ? 1.0 : 0.0)
                }

                // XP Progress Bar
                if showProgressBar {
                    VStack(spacing: 12) {
                        let oldLevelInfo = levelSystem.getLevelInfo(xp: oldXP)
                        let newLevelInfo = levelSystem.getLevelInfo(xp: newXP)

                        HStack {
                            Text(oldLevelInfo.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)

                            Spacer()

                            Text("\(newLevelInfo.xpRequired) / \(newLevelInfo.xpForNextLevel) XP")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 24)

                                // Old progress
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .green],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: animateProgress
                                            ? geometry.size.width * CGFloat(newLevelInfo.progressToNextLevel)
                                            : geometry.size.width * CGFloat(oldLevelInfo.progressToNextLevel),
                                        height: 24
                                    )
                                    .animation(.spring(response: 1.0, dampingFraction: 0.6), value: animateProgress)
                            }
                        }
                        .frame(height: 24)
                    }
                    .padding(.horizontal, 24)
                }

                // Level Up Animation
                if showLevelUp, let newLevel = levelSystem.getNewLevelIfLeveledUp(oldXP: oldXP, newXP: newXP) {
                    VStack(spacing: 16) {
                        Text("LEVEL UP!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .fontWidth(.expanded)

                            .scaleEffect(showLevelUp ? 1.2 : 0.5)

                        Text(newLevel.displayName)
                            .font(.system(size: 48))
                            .scaleEffect(showLevelUp ? 1.0 : 0.5)

                        // Confetti or sparkle effect
//                        HStack(spacing: 4) {
//                            ForEach(0..<5) { _ in
//                                Image(systemName: "sparkle")
//                                    .font(.title)
//                                    .foregroundColor(.yellow)
//                            }
//                        }
//                        .scaleEffect(showLevelUp ? 1.2 : 0.0)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                            .shadow(color: .yellow.opacity(0.3), radius: 20)
                    )
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Dismiss Button
                Button {
                    dismissView()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .fontWidth(.expanded)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? .white : .black)
                        )
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .opacity(showContent ? 1.0 : 0.0)
            }
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .shadow(radius: 20)
            )
            .padding(24)
            .scaleEffect(showContent ? 1.0 : 0.8)
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // Step 1: Show main content
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showContent = true
        }

        // Step 2: Show XP gain with bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                showXPGain = true
            }
        }

        // Step 3: Show progress bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showProgressBar = true

            // Step 4: Animate progress bar fill
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateProgress = true
            }
        }

        // Step 5: Check for level up and show animation
        if levelSystem.didLevelUp(oldXP: oldXP, newXP: newXP) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showLevelUp = true
                }

                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // Pulse animation
                withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
                    showLevelUp = true
                }
            }
        }
    }

    private func dismissView() {
        withAnimation(.easeOut(duration: 0.2)) {
            showContent = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}

// Preview
#Preview {
    StudySessionSummaryView(
        studyTime: 3600,
        xpGained: 60,
        oldXP: 250,
        newXP: 310,
        onDismiss: {}
    )
}
