//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  GroupStudyRoomViewNew.swift
//  Studyon
//
//  Created by Daniel Moreno on 9/3/25.
//

import SwiftUI

struct GroupStudyRoomViewNew: View {
    // Immutable inputs
    let roomId: String
    let currentUserId: String
    let isHost: Bool
    let pomodoroDuration: Int
    let breakDuration: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // ViewModel
    @StateObject private var vm: GroupStudyRoomViewModel
    @State private var phaseTotalSeconds: Double = 0
    @State private var lastPhase: String = ""

    // Custom initializer so we can pass params into @StateObject
    init(roomId: String, currentUserId: String, isHost: Bool, pomoDuration: Int, breakDuration: Int) {
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.isHost = isHost
        self.pomodoroDuration = pomoDuration
        self.breakDuration = breakDuration
        _vm = StateObject(wrappedValue: GroupStudyRoomViewModel(roomId: roomId, currentUserId: currentUserId, isHost: isHost))
    }

    var body: some View {
        GeometryReader { geo in
            let capsuleHeight = geo.size.height * 1.6
            let topY = -capsuleHeight / 2
            let bottomY = geo.size.height - capsuleHeight / 2
            // Progress over the entire phase duration using dynamically tracked total seconds
            let totalDurationSec = max(1.0, phaseTotalSeconds)
            let clampedRemaining = max(0.0, min(Double(vm.remainingSeconds), totalDurationSec))
            let progress = max(0.0, min(1.0, clampedRemaining / totalDurationSec))
            let capsuleY = topY + (bottomY - topY) * (1.0 - progress)
            
            ZStack {
                //Color(red: 250/255, green: 201/255, blue: 184/255)
                Color("background")
                
                Capsule()
                    .fill(colorScheme == .light ? Color.black.opacity(0.07) : Color.white.opacity(0.2))
                    .frame(width: geo.size.width * 1.18, height: capsuleHeight)
                    .position(x: geo.size.width / 2, y: capsuleY)
                    .animation(.easeInOut, value: progress)
                    .shadow(radius: 22, y: 12)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        
                        
                        Spacer()
                        
//                        Button {
//                           // vm.pauseToggle()
//                        } label: {
//                            Image(systemName: "ellipsis.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 27, height: 27)
//                                .foregroundStyle(colorScheme == .light ? .black : .white)
//                        }
                    }
                    
                    HStack {
                        Text(vm.roomTitle)
                            .font(.title)
                            .fontWeight(.black)
                            .fontWidth(.expanded)
                    }
                    
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text(vm.phase == "break" ? "Break - \(vm.breakLengthSec / 60) Minutes" : "Pomodoro - \(vm.pomodoroLengthSec / 60) Minutes")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.footnote)
                                Spacer()
                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text(vm.formattedRemaining())
                                    .font(.system(size: 70, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                Text("m")
                                    .font(.system(size: 35, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                   
                            }
                            
                            if isHost {
                                Button {
                                    if vm.remainingSeconds == 0 {
                                        // At boundary or idle: start appropriate phase
                                        if vm.phase == "break" {
                                            Task { await vm.startWork(durationSec: vm.pomodoroLengthSec) }
                                        } else {
                                            Task { await vm.startBreak(durationSec: vm.breakLengthSec) }
                                        }
                                    } else if vm.isPaused {
                                        Task { await vm.resume() }
                                    } else {
                                        Task { await vm.pause() }
                                    }
                                } label: {
                                    Image(systemName: (vm.isPaused || vm.remainingSeconds == 0) ? "play.fill" : "pause.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                }
                            }
                            
                            // Participants list
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Participants")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(vm.presence.values.filter { $0 == "online" }.count)/\(vm.presence.count) online")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(vm.presence.keys.sorted(), id: \.self) { uid in
                                            AsyncPresenceAvatar(uid: uid, state: vm.presence[uid] ?? "offline", name: vm.name(for: uid), vm: vm)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 23)
                .padding(.top, geo.safeAreaInsets.top + 10)
            }
            .ignoresSafeArea()
            .onAppear {
                vm.start()
                lastPhase = vm.phase
                phaseTotalSeconds = max(1.0, Double(vm.remainingSeconds))
            }
            .onChange(of: vm.phase) { newPhase in
                lastPhase = newPhase
                // Reset total when phase changes; use current remaining as the new total
                phaseTotalSeconds = max(1.0, Double(vm.remainingSeconds))
            }
            .onChange(of: vm.remainingSeconds) { newValue in
                // If timer resets/increases (new phase or user-chosen duration), capture as new total
                let newRemaining = Double(newValue)
                if newRemaining > phaseTotalSeconds {
                    phaseTotalSeconds = newRemaining
                }
            }
            .onDisappear { vm.stop() }
        }
    }
}

#Preview {
    GroupStudyRoomViewNew(roomId: "demoRoom", currentUserId: "u1", isHost: true, pomoDuration: 25, breakDuration: 5)
}

private struct PresenceAvatar: View {
    let uid: String
    let state: String // "online" | "offline"
    let profileImageURL: URL?
    let name: String?
    

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                if let url = profileImageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color(.systemGray5)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Circle()    // generic circle if theres no image url being passed in
                        .fill(Color(.systemGray5))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(initials())
                                .font(.caption2).bold()
                                .foregroundStyle(.secondary)
                        )
                }
                Circle()
                    .fill(state == "online" ? .green : .gray)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            Text(firstName())
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 44)
        }
    }
    
    private func displayName() -> String {
        if let name, !name.isEmpty { return name }
        return uid
    }
    
    private func initials() -> String {
        // Get a clean display name
        let base = displayName()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split into words by whitespace
        let parts = base.split(whereSeparator: { $0.isWhitespace })
        
        // Extract first letter of first and last word (if present),
        // keeping only alphanumeric characters.
        var result = ""
        if let first = parts.first?.first, (first.isLetter || first.isNumber) {
            result.append(first)
        } else if let firstWord = parts.first {
            // find first alphanumeric in the first word
            if let ch = firstWord.first(where: { $0.isLetter || $0.isNumber }) {
                result.append(ch)
            }
        }
        
        if parts.count >= 2 {
            if let last = parts.last?.first, (last.isLetter || last.isNumber) {
                result.append(last)
            } else if let lastWord = parts.last {
                if let ch = lastWord.first(where: { $0.isLetter || $0.isNumber }) {
                    result.append(ch)
                }
            }
        }
        
        // If we still don't have anything (e.g., emojis only), fall back to previous logic
        if result.isEmpty {
            let letters = base.filter { $0.isLetter || $0.isNumber }
            result = String(letters.prefix(2))
        }
        
        return result.uppercased()
    }

    private func firstName() -> String {
        let display = displayName().trimmingCharacters(in: .whitespacesAndNewlines)
        if display.isEmpty { return "" }
        let parts = display.split(separator: " ")
        if let first = parts.first {
            return String(first)
        }
        return display
    }
}

private struct AsyncPresenceAvatar: View {
    let uid: String
    let state: String
    let name: String?
    let vm: GroupStudyRoomViewModel
    
    @State private var url: URL? = nil
    @State private var displayName: String? = nil
    var body: some View {
        PresenceAvatar(uid: uid, state: state, profileImageURL: url, name: displayName ?? name)
            .task(id: uid) {
                // Safely attempt to load the profile image URL asynchronously
                url = try? await vm.profilePhotoURL(for: uid)
                displayName = try? await vm.name(for: uid)
                
            }
    }
}

