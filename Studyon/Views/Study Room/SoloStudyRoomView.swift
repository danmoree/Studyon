//
//  SoloStudyRoomView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/9/25.
//

import SwiftUI

struct SoloStudyRoomView: View {
    let studyRoom: SoloStudyRoom
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SoloStudyRoomViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    
    
    init(studyRoom: SoloStudyRoom) {
        self.studyRoom = studyRoom
        _viewModel = StateObject(wrappedValue: SoloStudyRoomViewModel(studyRoom: studyRoom))
    }
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 250/255, green: 201/255, blue: 184/255)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.black)
                        }
                        
                        Spacer()
                        
                        Button {
                           // viewModel.pauseToggle()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27)
                                .foregroundStyle(.black)
                        }
                    }
                    
                    HStack {
    if let user = userVM.user {
        Text("\(user.fullName?.split(separator: " ").first.map(String.init) ?? "User")'s Study \nRoom ☕️")
            .font(.title)
            .fontWeight(.black)
            .fontWidth(.expanded)
                        }
                        
                    }
                    
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text(viewModel.isOnBreak ? "Break - \(studyRoom.pomBreakDurationSec / 60) Minutes" : "Pomodoro - \(studyRoom.pomDurationSec / 60) Minutes")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.footnote)
                                Spacer()
                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text(viewModel.timeString())
                                    .font(.system(size: 70, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                Text("m")
                                    .font(.system(size: 35, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                   
                            }
                            
                            
                            Button {
                                viewModel.pauseToggle()
                            } label: {
                                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.black)
                            }
                            .padding(.top, 20)
                            
                            
                            
                        }
                    }
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 23)
                .padding(.top, geo.safeAreaInsets.top + 10)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    SoloStudyRoomView(
        studyRoom: SoloStudyRoom(
            createAt: Date(),
            pomIsRunning: true,
            pomDurationSec: 1500,
            pomBreakDurationSec: 300
        )
    )
    .environmentObject(ProfileViewModel())
}
