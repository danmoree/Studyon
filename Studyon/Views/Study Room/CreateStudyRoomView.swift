//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  CreateStudyRoomView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateStudyRoomView: View {
    @Binding var showCreateStudyRoom: Bool
    @State private var progress: Double = 0
    @State private var showCreateStudyRoomSolo = false
    @State var showGroupView = false
    @Environment(\.colorScheme) var colorScheme
    @State private var createdRoomId: String? = nil
    
    var body: some View {
        VStack {
            VStack {
                // Title
                HStack {
                    Text("Create a room! 📚")
                        .font(.title)
                        .bold()
                        .fontWidth(.expanded)
                    Spacer()
                    
                    Button {
                        showCreateStudyRoom = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                        
                    }
                    
                }
                
            }
            .padding(.horizontal, 23)
            .padding(.top, 20)
        }
        
        
        HStack {
            
            // solo
            VStack(spacing: 12) {
                HStack {
                    Text("Solo \nSession")
                        .fontWidth(.expanded)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                
                Text("Just you")
                    .fontWeight(.light)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .font(.caption)
                    .fontWidth(.expanded)
                
                Spacer()
                
                Button {
                    showCreateStudyRoomSolo = true
                } label: {
                    Text("Configure")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.vertical, 15)
                        .background {
                            Capsule().fill(.black)
                        }
                }
                
            }
            .frame(alignment: .top)
            .padding()
            .frame(width: 160.16, height: 227.76)
            .background(Color(red: 183/255, green: 225/255, blue: 147/255))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            
            // group
            VStack(spacing: 12) {
                HStack {
                    Text("Group \nSession")
                        .fontWidth(.expanded)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: "person.3.fill")
                  .resizable()
                  .frame(width: 60, height: 30)
                  .foregroundStyle(colorScheme == .light ? .white : .black)
                  .symbolRenderingMode(.hierarchical)
                  .symbolEffect(
                    .variableColor.cumulative.dimInactiveLayers.reversing,
                    options: .repeat(.continuous),
                    isActive: true   
                  )
                
                Text("With friends")
                    .fontWeight(.light)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .font(.caption)
                    .fontWidth(.expanded)
                
                Spacer()
                
                Button {
                    // Generate Firestore roomId and create an empty room doc
                    let newRoomId = Firestore.firestore().collection("rooms").document().documentID
                    
                    // Optionally create the room document now so it exists before opening view
                    Firestore.firestore().collection("rooms").document(newRoomId).setData([
                        "room_id": newRoomId,
                        "host_id": Auth.auth().currentUser?.uid ?? "",
                        "created_at": FieldValue.serverTimestamp(),
                        "member_ids": [Auth.auth().currentUser?.uid ?? ""]
                    ])
                    
                    // Save and show the view
                    self.createdRoomId = newRoomId
                    showGroupView = true
                } label: {
                    Text("Configure")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.vertical, 15)
                        .background {
                            Capsule().fill(.black)
                        }
                }
                
            }
            .frame(alignment: .top)
            .padding()
            .frame(width: 160.16, height: 227.76)
            .background(Color(red: 183/255, green: 225/255, blue: 147/255))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .sheet(isPresented: $showCreateStudyRoomSolo) {
            CreateStudyRoomSoloView(showCreateStudyRoomSolo: $showCreateStudyRoomSolo)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showGroupView) {
            Group {
                if let createdRoomId {
                    GroupStudyRoomView(
                        roomId: createdRoomId,
                        currentUserId: Auth.auth().currentUser?.uid ?? "unknown",
                        isHost: true
                    )
                } else {
                    // Optionally provide an empty view or loading indicator if needed
                    EmptyView()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        
    }
}

#Preview {
    CreateStudyRoomView(showCreateStudyRoom: .constant(true))
}
