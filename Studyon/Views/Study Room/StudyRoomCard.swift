//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  StudyRoomCard.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI

struct StudyRoomCard: View {
    @Binding var hideTabBar: Bool
    
    let title: String
    let startTime: String
    let endTime: String
    let creatorUsername: String
    let pomoDuration: Int
    let pomoBreakDuration: Int
    
    let studyRoom: StudyRoom?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                // top description, time
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.black)
                    .fontWeight(.light)
                    .fontWidth(.expanded)
                    .lineLimit(2)            // up to two lines
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Spacer(minLength: 8)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 0.5, height: 30)

                Spacer(minLength: 8)

                (
                    Text(startTime).font(.footnote) +
                    Text(" - \n\(endTime) ").font(.footnote)
                )
                .foregroundColor(.black)
                .fontWidth(.expanded)
                .fontWeight(.light)
                .fixedSize()
            }
            Spacer()
            HStack {
                // creators room title
                Text("\(creatorUsername)'s \nStudy Room 🤓")
                    .font(.body)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                
                Spacer()
            }
            
            Spacer()
            VStack {
                // bottom description
                HStack {
                    // Pomodoro
                    Text("Pomodoro")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
                HStack {
                    // study time amount
                    Text("Study \(pomoDuration / 60)m")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
                HStack {
                    // break time amount
                    Text("Break \(pomoBreakDuration / 60)m")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                // members pfp
                // join button
                HStack {
                    HStack(spacing: -4) {
                        ForEach(0..<3) { index in
                            Image("profile_pic\(index + 1)")// Replace with actual image names or URLs
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                            
                            
                        }
                        
                        
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 25, height: 25)
                            Text("+4")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .fontWidth(.expanded)
                        }
                        
                        
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ActualStudyRoomView(studyRoom: studyRoom)
                        .onAppear { hideTabBar = true}
                        .onDisappear { hideTabBar = false}) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.black)
                    }
                    
                    
                    
                }
            }
        }
        .frame(alignment: .top)
        .padding()
        .frame(width: 200.2, height: 284.7)
        .background(Color(red: 183/255, green: 225/255, blue: 147/255))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    @Previewable var selectedRoom: StudyRoom?
    
    StudyRoomCard(hideTabBar: .constant(true), title: "CS 471 Study", startTime: "11:00 AM", endTime: "1:00 PM", creatorUsername: "danmore", pomoDuration: 1800, pomoBreakDuration: 600,  studyRoom: selectedRoom ?? nil)
}
