//
//  StudyRoomCard.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/4/25.
//

import SwiftUI

struct StudyRoomCard: View {
    @Binding var hideTabBar: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                // top description, time
                Text("Diff\u{00A0}eq\nHW")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .fontWeight(.light)
                    .fontWidth(.expanded)
                    .fixedSize(horizontal: true, vertical: true)
                
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 0.5, height: 30)
                        Spacer()
                    }
                    .frame(width: geo.size.width / 0.8)
                }
                
                (
                    Text("8:00 ").font(.footnote) +
                    Text("PM").font(.caption2) +
                    Text(" - \n10:00 ").font(.footnote) +
                    Text("PM").font(.caption2)
                )
                .foregroundColor(.black)
                .fontWidth(.expanded)
                .fontWeight(.light)
                .fixedSize()
                
            }
            
            HStack {
                // creators room title
                Text("Danmore's \nStudy Room 🤓")
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
                    Text("Study 30m")
                        .foregroundColor(.black).opacity(0.5)
                        .fontWidth(.expanded)
                        .font(.footnote)
                    
                    Spacer()
                }
                HStack {
                    // break time amount
                    Text("Break 10m")
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
                    
                    NavigationLink(destination: ActualStudyRoomView()
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
    StudyRoomCard(hideTabBar: .constant(true))
}
