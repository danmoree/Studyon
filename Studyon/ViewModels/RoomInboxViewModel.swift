//
//  RoomInboxViewModel.swift
//  Studyon
//
//  Created by Claude on 1/19/26.
//

import Foundation
import FirebaseFirestore
import Combine

final class RoomInboxViewModel: ObservableObject {
    @Published var pendingInvites: [RoomLink] = []
    @Published var upcomingRooms: [GroupStudyRoom] = []
    @Published var activeRooms: [GroupStudyRoom] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var pendingInvitesListener: ListenerRegistration?
    private var upcomingRoomsListener: ListenerRegistration?

    // MARK: - Lifecycle

    func startListening() {
        print("RoomInboxViewModel: Starting listeners")
        listenToPendingInvites()
        listenToAcceptedRooms()
    }

    func stopListening() {
        print("RoomInboxViewModel: Stopping listeners")
        pendingInvitesListener?.remove()
        pendingInvitesListener = nil
        upcomingRoomsListener?.remove()
        upcomingRoomsListener = nil
    }

    deinit {
        // Clean up listeners synchronously to avoid retain cycles
        pendingInvitesListener?.remove()
        upcomingRoomsListener?.remove()
    }

    // MARK: - Listen to Pending Invites

    private func listenToPendingInvites() {
        pendingInvitesListener = RoomInvitationManager.shared.listenToPendingInvites { [weak self] roomLinks in
            Task { @MainActor in
                self?.pendingInvites = roomLinks
            }
        }
    }

    // MARK: - Listen to Accepted Rooms (with time-based filtering)

    private func listenToAcceptedRooms() {
        upcomingRoomsListener = RoomInvitationManager.shared.listenToUpcomingRooms { [weak self] roomLinks in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                await self?.fetchAndFilterRooms(from: roomLinks)
            }
        }
    }

    // MARK: - Fetch Full Room Data and Filter by Time

    private func fetchAndFilterRooms(from roomLinks: [RoomLink]) async {
        var upcoming: [GroupStudyRoom] = []
        var active: [GroupStudyRoom] = []

        let now = Date()

        for roomLink in roomLinks {
            do {
                // Fetch full GroupStudyRoom from Firestore
                let roomDoc = try await Firestore.firestore()
                    .collection("rooms")
                    .document(roomLink.roomId)
                    .getDocument()

                guard let room = try? roomDoc.data(as: GroupStudyRoom.self) else {
                    print("Failed to decode room: \(roomLink.roomId)")
                    continue
                }

                // Filter by time: if startTime has passed, it's active; otherwise upcoming
                if let startTime = room.startTime {
                    if startTime <= now {
                        // Room has started - it's active
                        active.append(room)
                    } else {
                        // Room hasn't started yet - it's upcoming
                        upcoming.append(room)
                    }
                } else {
                    // No start time, treat as upcoming
                    upcoming.append(room)
                }
            } catch {
                print("Error fetching room \(roomLink.roomId): \(error.localizedDescription)")
            }
        }

        // Sort upcoming by start time (earliest first)
        let sortedUpcoming = upcoming.sorted {
            ($0.startTime ?? Date.distantPast) < ($1.startTime ?? Date.distantPast)
        }

        // Sort active by start time (most recent first)
        let sortedActive = active.sorted {
            ($0.startTime ?? Date.distantPast) > ($1.startTime ?? Date.distantPast)
        }

        // Update @Published properties on main thread
        await MainActor.run {
            self.upcomingRooms = sortedUpcoming
            self.activeRooms = sortedActive
            print("RoomInboxViewModel: \(sortedActive.count) active rooms, \(sortedUpcoming.count) upcoming rooms")
        }
    }

    // MARK: - Accept/Decline Actions

    func acceptInvite(roomId: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            try await RoomInvitationManager.shared.acceptInvite(roomId: roomId)
            print("Successfully accepted invite for room: \(roomId)")
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            print("Error accepting invite: \(error.localizedDescription)")
        }

        await MainActor.run {
            isLoading = false
        }
    }

    func declineInvite(roomId: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            try await RoomInvitationManager.shared.declineInvite(roomId: roomId)
            print("Successfully declined invite for room: \(roomId)")
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            print("Error declining invite: \(error.localizedDescription)")
        }

        await MainActor.run {
            isLoading = false
        }
    }
}
