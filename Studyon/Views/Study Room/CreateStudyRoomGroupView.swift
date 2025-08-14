//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  CreateStudyRoomGroupView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/13/25.
//

import SwiftUI

struct CreateStudyRoomGroupView: View {
    @Binding var showCreateStudyRoomGroup: Bool
    @State private var pomDuration: Int = 25 * 60
    @State private var pomBreakDuration: Int = 5 * 60
    @State private var newGroupRoom: GroupStudyRoom? = nil
    @State private var title: String = ""
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var isPrivate: Bool = false
    // if private then need to open detailed room view, so user can send out invites
    @Binding var openRoomDetailedView: Bool
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    CreateStudyRoomGroupView(showCreateStudyRoomGroup: .constant(true), openRoomDetailedView: .constant(false))
}
