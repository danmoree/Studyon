//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  CreateStudyRoomSoloView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/9/25.
//

import SwiftUI

struct CreateStudyRoomSoloView: View {
    @Binding var showCreateStudyRoomSolo: Bool
    @State private var pomDuration: Int = 25 * 60 // min to seconds
    @State private var pomBreakDuration: Int = 5 * 60
    @State private var newSoloRoom: SoloStudyRoom? = nil
    var body: some View {
        VStack {
            
            // title/close
            VStack {
                // Title
                HStack {
                    Text("Create session! ⏱️")
                        .font(.title)
                        .bold()
                        .fontWidth(.expanded)
                    
                    Spacer()
                    
                    Button {
                        showCreateStudyRoomSolo = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                    }
                    
                }
            }
            .padding(.top, 20)
            
            // Pomo dur
            VStack {

                Text(String(pomDuration / 60) + ":00")
                    .font(.system(size: 70, weight: .black))
                    .fontWeight(.black)
                    .fontWidth(.expanded)
                
                HStack {
                    Text("Pomodoro duration")
                        .fontWeight(.thin)
                        .fontWidth(.expanded)
                    
                    
                }
                
                Slider(
                    value: Binding(
                        get: { Double(pomDuration / 60)},
                        set: { newValue in pomDuration = Int(newValue) * 60 }
                    ),
                    in: 1...60,
                    step: 5
                )
                .accentColor(.black)
            }
            .padding(.top, 20)
            
            // break dur
            VStack {

                Text(String(pomBreakDuration / 60) + ":00")
                    .font(.system(size: 35, weight: .black))
                    .fontWeight(.black)
                    .fontWidth(.expanded)
                
                HStack {
                    Text("Break duration")
                        .fontWeight(.thin)
                        .fontWidth(.expanded)
                    
                    
                }
                
                Slider(
                    value: Binding(
                        get: { Double(pomBreakDuration / 60)},
                        set: { newValue in pomBreakDuration = Int(newValue) * 60 }
                    ),
                    in: 1...10,
                    step: 1
                )
                .accentColor(.black)

                
            }
            .padding(.top, 20)
            
           
            Button {
                // init room
                newSoloRoom = SoloStudyRoom(createAt: Date(), pomIsRunning: true, pomDurationSec: pomDuration, pomBreakDurationSec: pomBreakDuration)
                
                
            } label: {
                Text("Start")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .padding(.vertical, 15)
                    .background {
                        Capsule().fill(.black)
                    }
            }
            
        }
        .padding(.horizontal, 23)
        .fullScreenCover(item: $newSoloRoom) { room in
            SoloStudyRoomView(studyRoom: room)
        }
    }
    
}

#Preview {
    CreateStudyRoomSoloView(showCreateStudyRoomSolo: .constant(true))
}
