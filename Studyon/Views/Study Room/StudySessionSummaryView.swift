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
    let groupBonus: Int? // Optional: bonus XP for group study rooms

    @State private var showContent = false
    @State private var showXPGain = false
    @State private var showProgressBar = false
    @State private var animateProgress = false
    @State private var showLevelUp = false
    @State private var levelUpScale: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme

    private let levelSystem = LevelSystem.shared

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Session Complete")
                        .font(.system(size: 32, weight: .bold))
                        .fontWidth(.expanded)
                        .opacity(showContent ? 1.0 : 0.0)
                }
                .padding(.top, 60)

                // Stats Grid
                VStack(spacing: 40) {
                    // Study Time
                    VStack(spacing: 8) {
                        Text("TIME STUDIED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                            .foregroundStyle(.secondary)
                            .tracking(2)

                        Text(formatTime(studyTime))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .fontWidth(.expanded)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)

                    // XP Gained
                    VStack(spacing: 8) {
                        Text("XP GAINED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                            .foregroundStyle(.secondary)
                            .tracking(2)

                        if let bonus = groupBonus {
                            let baseXP = xpGained - bonus
                            VStack(spacing: 4) {
                                Text("+\(xpGained)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .fontWidth(.expanded)

                                Text("\(baseXP) × 40% = \(bonus) bonus")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("+\(xpGained)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .fontWidth(.expanded)
                        }
                    }
                    .opacity(showXPGain ? 1.0 : 0.0)
                    .offset(y: showXPGain ? 0 : 20)
                }

                // Level & Progress Section
                if showProgressBar {
                    VStack(spacing: 24) {
                        let oldLevelInfo = levelSystem.getLevelInfo(xp: oldXP)
                        let newLevelInfo = levelSystem.getLevelInfo(xp: newXP)
                        let didLevelUp = levelSystem.didLevelUp(oldXP: oldXP, newXP: newXP)

                        // Level-up announcement
                        if showLevelUp && didLevelUp {
                            VStack(spacing: 8) {
                                Text("LEVEL UP")
                                    .font(.system(size: 28, weight: .black))
                                    .fontWidth(.expanded)
                                    .tracking(3)
                                    .scaleEffect(levelUpScale)
                                    .transition(.scale.combined(with: .opacity))

                                Text(newLevelInfo.displayName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .scaleEffect(levelUpScale)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLevelUp)
                        }

                        // Level and XP info
                        VStack(spacing: 16) {
                            HStack {
                                if showLevelUp && didLevelUp {
                                    Text(newLevelInfo.displayName)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontWidth(.expanded)
                                        .transition(.scale.combined(with: .opacity))
                                } else {
                                    Text(oldLevelInfo.displayName)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontWidth(.expanded)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                Spacer()

                                Text("\(newLevelInfo.xpRequired) / \(newLevelInfo.xpForNextLevel) XP")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLevelUp)

                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 8)

                                    // Progress fill
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(colorScheme == .dark ? Color.white : Color.black)
                                        .frame(
                                            width: animateProgress
                                                ? geometry.size.width * CGFloat(newLevelInfo.progressToNextLevel)
                                                : geometry.size.width * CGFloat(oldLevelInfo.progressToNextLevel),
                                            height: 8
                                        )
                                        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: animateProgress)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                // Dismiss Button
                Button {
                    dismissView()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .tracking(1)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? .white : .black)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(showContent ? 1.0 : 0.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("background").ignoresSafeArea())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                // Show level up
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showLevelUp = true
                }

                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // Pulse animation for level text
                withAnimation(.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true)) {
                    levelUpScale = 1.08
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        levelUpScale = 1.0
                    }
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
        onDismiss: {},
        groupBonus: nil
    )
}
