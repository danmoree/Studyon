//
//  ActualStudyRoomView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/5/25.
//

import SwiftUI

struct ActualStudyRoomView: View {
    let studyRoom: StudyRoom?
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 250/255, green: 201/255, blue: 184/255)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.black)
                        }
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27)
                                .foregroundStyle(.black)
                        }
                    }
                    
                    HStack {
                        Text("\(studyRoom?.creatorId ?? "Unknown")'s Study \nRoom ☕️")
                            .font(.title)
                            .fontWeight(.black)
                            .fontWidth(.expanded)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Total Focused")
                        Text("2h 42m") // create func that adds up time studied
                            .fontWeight(.bold)
                    }
                    .fontWidth(.expanded)
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Pomodoro - \((studyRoom?.pomDurationSec ?? 0) * 60) Minutes")
                                    .fontWeight(.bold)
                                    .fontWidth(.expanded)
                                    .font(.footnote)
                                Spacer()
                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text("11:23") // calculate time left based on start time and current time
                                    .font(.system(size: 70, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                Text("m")
                                    .font(.system(size: 35, weight: .black))
                                    .fontWeight(.black)
                                    .fontWidth(.expanded)
                                   
                            }
                            
                            Text("left")
                                .font(.title2)
                                .fontWidth(.expanded)
                            
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
    @Previewable var selectedRoom: StudyRoom?
    
    ActualStudyRoomView(studyRoom: selectedRoom ?? nil)
}
