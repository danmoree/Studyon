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

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // ViewModel
    @StateObject private var vm: GroupStudyRoomViewModel

    // Custom initializer so we can pass params into @StateObject
    init(roomId: String, currentUserId: String, isHost: Bool) {
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.isHost = isHost
        _vm = StateObject(wrappedValue: GroupStudyRoomViewModel(roomId: roomId, currentUserId: currentUserId, isHost: isHost))
    }

    var body: some View {
        GeometryReader { geo in
            let capsuleHeight = geo.size.height * 1.6
            let topY = -capsuleHeight / 2
            let bottomY = geo.size.height - capsuleHeight / 2
            let progress = min(1.0, max(0.0, Double(vm.remainingSeconds % 60) / 60.0))
            let capsuleY = topY + (bottomY - topY) * (progress * 1.12)
            
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
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                        }
                        
                        
                        Spacer()
                        
                        Button {
                           // vm.pauseToggle()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27)
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                        }
                    }
                    
                    HStack {
                        Text(isHost ? "Host Room ☕️" : "Study Room ☕️")
                            .font(.title)
                            .fontWeight(.black)
                            .fontWidth(.expanded)
                    }
                    
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text(vm.phase == "break" ? "Break - \((vm.isPaused ? max(vm.remainingSeconds, 0) : vm.remainingSeconds) / 60) Minutes" : "Pomodoro - \((vm.isPaused ? max(vm.remainingSeconds, 0) : vm.remainingSeconds) / 60) Minutes")
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
                                            Task { await vm.startWork(durationSec: 25 * 60) }
                                        } else {
                                            Task { await vm.startBreak(durationSec: 5 * 60) }
                                        }
                                    } else if vm.isPaused {
                                        Task { await vm.resume() }
                                    } else {
                                        Task { await vm.pause() }
                                    }
                                } label: {
                                    Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
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
                                            PresenceAvatar(uid: uid, state: vm.presence[uid] ?? "offline", profileImageURL: nil)
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
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }
        }
    }
}

#Preview {
    GroupStudyRoomViewNew(roomId: "demoRoom", currentUserId: "u1", isHost: true)
}

private struct PresenceAvatar: View {
    let uid: String
    let state: String // "online" | "offline"
    let profileImageURL: URL?
    var body: some View {
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
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials(from: uid))
                            .font(.caption2).bold()
                            .foregroundStyle(.secondary)
                    )
            }
            Circle()
                .fill(state == "online" ? .green : .gray)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
        .accessibilityLabel("\(uid) is \(state)")
    }

    private func initials(from s: String) -> String {
        let letters = s.filter { $0.isLetter || $0.isNumber }
        return String(letters.prefix(2)).uppercased()
    }
}

