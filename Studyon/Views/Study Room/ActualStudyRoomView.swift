//////
//////  Created by Daniel Moreno on 2025
//////  © 2025 Daniel Moreno. All rights reserved.
//////  This code is proprietary and confidential.
//////  Do not copy, distribute, or reuse without written permission.
//////
//////  ActualStudyRoomView.swift
//////  Studyon
//////
//////  Created by Daniel Moreno on 6/5/25.
//////
//
//import SwiftUI
//
//struct ActualStudyRoomView: View {
//    let studyRoom: GroupStudyRoom
//    var body: some View {
//        GeometryReader { geo in
//            ZStack {
//                Color(red: 250/255, green: 201/255, blue: 184/255)
//                
//                VStack(alignment: .leading, spacing: 16) {
//                    HStack {
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: "chevron.left")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 25, height: 25)
//                                .foregroundStyle(.black)
//                        }
//                        
//                        Spacer()
//                        
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: "ellipsis.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 27, height: 27)
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    
//                    HStack {
//                        Text("\(studyRoom.creatorId)'s Study \nRoom ☕️")
//                            .font(.title)
//                            .fontWeight(.black)
//                            .fontWidth(.expanded)
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text("Total Focused")
//                        // Placeholder for total focused time display
//                        Text("N/A")
//                            .fontWeight(.bold)
//                    }
//                    .fontWidth(.expanded)
//                    
//                    Spacer()
//                    
//                    ZStack {
//                        VStack {
//                            HStack {
//                                Spacer()
//                                if let pomDuration = studyRoom.pomodoroDuration {
//                                    Text("Pomodoro - \(pomDuration) Minutes")
//                                        .fontWeight(.bold)
//                                        .fontWidth(.expanded)
//                                        .font(.footnote)
//                                } else {
//                                    Text("Pomodoro - N/A Minutes")
//                                        .fontWeight(.bold)
//                                        .fontWidth(.expanded)
//                                        .font(.footnote)
//                                }
//                                Spacer()
//                            }
//                            
//                            HStack(alignment: .firstTextBaseline) {
//                                if let timer = studyRoom.timer {
//                                    let timeLeftSec = timer.timeLeft
//                                    let minutesLeft = Int(timeLeftSec) / 60
//                                    let secondsLeft = Int(timeLeftSec) % 60
//                                    Text(String(format: "%02d:%02d", minutesLeft, secondsLeft))
//                                        .font(.system(size: 70, weight: .black))
//                                        .fontWeight(.black)
//                                        .fontWidth(.expanded)
//                                } else {
//                                    Text("00:00")
//                                        .font(.system(size: 70, weight: .black))
//                                        .fontWeight(.black)
//                                        .fontWidth(.expanded)
//                                }
//                                Text("m")
//                                    .font(.system(size: 35, weight: .black))
//                                    .fontWeight(.black)
//                                    .fontWidth(.expanded)
//                                   
//                            }
//                            
//                            Text("left")
//                                .font(.title2)
//                                .fontWidth(.expanded)
//                            
//                        }
//                    }
//                    Spacer()
//                    Spacer()
//                }
//                .padding(.horizontal, 23)
//                .padding(.top, geo.safeAreaInsets.top + 10)
//            }
//            .ignoresSafeArea()
//        }
//    }
//}
//
//#Preview {
//    let timer = TimerModel(phase: .focus, timeLeft: 11 * 60 + 23)
//    let exampleGroupStudyRoom = GroupStudyRoom(
//        creatorId: "JohnDoe",
//        title: "Study Room",
//        pomodoroDuration: 25,
//        timer: timer
//    )
//    ActualStudyRoomView(studyRoom: exampleGroupStudyRoom)
//}
