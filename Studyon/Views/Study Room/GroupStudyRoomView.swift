//
//  GroupStudyRoomView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/12/25.
//

import SwiftUI

struct GroupStudyRoomView: View {
    // Immutable inputs
    let roomId: String
    let currentUserId: String
    let isHost: Bool

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
        VStack(spacing: 24) {
            header
            timerBlock
            presenceBlock
            if isHost { hostControls }
            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("Study Room")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Sections
    private var header: some View {
        HStack {
            Label(isHost ? "You are host" : "Participant", systemImage: isHost ? "crown" : "person.2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            PhasePill(phase: vm.phase, isPaused: vm.isPaused)
        }
    }

    private var timerBlock: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(.quaternary, lineWidth: 14)
                    .frame(width: 220, height: 220)
                // Progress ring (optional simple approximation)
                RingProgress(value: progressValue)
                    .frame(width: 220, height: 220)
                VStack(spacing: 8) {
                    Text(vm.formattedRemaining())
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text(vm.phase == "work" ? "Focus" : "Break")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if vm.isPaused { Text("Paused").font(.caption).foregroundStyle(.secondary) }
                }
            }
        }
    }

    private var presenceBlock: some View {
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
                    // Use a synchronous cache of profile photo URLs published by the view model,
                    // to avoid calling async code from the view.
                    ForEach(vm.presence.keys.sorted(), id: \.self) { uid in
                        AsyncProfileAvatar(uid: uid, state: vm.presence[uid] ?? "offline", vm: vm)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var hostControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    Task { await vm.startWork(durationSec: 25 * 60) }
                } label: { Label("Start 25:00", systemImage: "play.circle") }
                .buttonStyle(.borderedProminent)

                Button {
                    Task { await vm.startBreak(durationSec: 5 * 60) }
                } label: { Label("Break 5:00", systemImage: "cup.and.saucer") }
                .buttonStyle(.bordered)
            }
            HStack(spacing: 12) {
                Button {
                    Task { await vm.pause() }
                } label: { Label("Pause", systemImage: "pause.fill") }
                .buttonStyle(.bordered)
                .disabled(vm.isPaused)

                Button {
                    Task { await vm.resume() }
                } label: { Label("Resume", systemImage: "play.fill") }
                .buttonStyle(.bordered)
                .disabled(!vm.isPaused)
            }
        }
    }

    // MARK: - Helpers
    private var progressValue: Double {
        // Best-effort visual: if paused and we know remaining, we cannot know the original duration reliably.
        // We'll show a simple pulsing ring when running and a thin ring when paused.
        // (You can enhance by storing original duration in view model if you prefer exact progress.)
        if vm.isPaused { return 0 }
        // Without total, we can't compute fraction; show a small animated sweep using remainingSeconds modulo.
        return 1 - (Double(vm.remainingSeconds % max(vm.remainingSeconds, 1)) / Double(max(vm.remainingSeconds, 1)))
    }
}

// MARK: - Subviews
private struct PhasePill: View {
    let phase: String
    let isPaused: Bool
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: phase == "work" ? "bolt.fill" : "leaf.fill")
            Text(phase == "work" ? "Work" : "Break")
            if isPaused { Text("• Paused") }
        }
        .font(.caption)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.thinMaterial, in: Capsule())
    }
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
        // Cheap placeholder: take first 2 alphanumerics
        let letters = s.filter { $0.isLetter || $0.isNumber }
        return String(letters.prefix(2)).uppercased()
    }
}

private struct AsyncProfileAvatar: View {
    let uid: String
    let state: String
    let vm: GroupStudyRoomViewModel
    @State private var url: URL? = nil
    var body: some View {
        PresenceAvatar(uid: uid, state: state, profileImageURL: url)
            .task {
                url = try? await vm.profilePhotoURL(for: uid)
            }
    }
}

private struct RingProgress: View {
    let value: Double // 0...1
    var body: some View {
        Circle()
            .trim(from: 0, to: max(0, min(1, value)))
            .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .foregroundStyle(.tint)
    }
}

#Preview {
    NavigationStack {
        GroupStudyRoomView(roomId: "demoRoom", currentUserId: "u1", isHost: true)
    }
}
