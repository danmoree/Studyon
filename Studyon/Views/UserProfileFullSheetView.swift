//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  UserProfileFullSheetView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/28/25.
//

import SwiftUI

private func formatHoursMinutes(from seconds: TimeInterval) -> String {
    let totalMinutes = Int(seconds) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}

fileprivate struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double = 2.2
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    Rectangle()
                        .fill(gradient)
                        .frame(width: width * 0.6)
                        .offset(x: -width * 0.6 + phase * (width + width * 0.6))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct UserProfileFullSheetView: View {
    let user: DBUser
    @ObservedObject var socialVM: SocialViewModel
    @ObservedObject var profileVM: ProfileViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    @Binding var isUserLoggedIn: Bool
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                // top buttons
                HStack {
                    Spacer()
                    
//                    Button {
//                        // code
//                    } label: {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.black)
//                                .frame(width: 40, height: 40)
//
//                            Image(systemName: "paperplane.fill")
//                                .foregroundColor(.white)
//                        }
//                    }
                    
                    Button  {
                        showingSettings = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colorScheme == .light ? Color.black : Color.white)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "gear")
                                .foregroundColor(colorScheme == .light ? .white : .black)
                                .rotationEffect(.degrees(90))
                        }
                    }

                    
                    
                    
                    
                }
                VStack(alignment: .center) {
                    ZStack {
                        
                        if let image = profileVM.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(
                                    color: (user.isOnline == true ? Color.green : Color.gray).opacity(0.2),
                                    radius: 20, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colorScheme == .light ? Color.black : Color.gray, lineWidth: 1.5)
                                )
                            
                            Circle()
                                .fill(user.isOnline == true ? Color.green : Color.gray)
                                .frame(width: 20, height: 20)
                                .padding(.leading, 60)
                                .padding(.top, 60)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(
                                    color: (user.isOnline == true ? Color.green : Color.gray).opacity(0.2),
                                    radius: 20, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colorScheme == .light ? Color.black : Color.gray, lineWidth: 1.5)
                                )
                            
                            Circle()
                                .fill(user.isOnline == true ? Color.green : Color.gray)
                                .frame(width: 20, height: 20)
                                .padding(.leading, 60)
                                .padding(.top, 60)
                        }
                        
         
                    }
                    
                    
                    Text(user.fullName ?? "User")
                        .font(.title).bold()
                        .fontWidth(.expanded)
                    Text("@\(user.username ?? "username")")
                        .fontWidth(.expanded)
                        .opacity(0.4)
                        .font(.callout)
                    
                    if user.isOnline == true {
                        Text("Online")
                            .fontWidth(.expanded)
                            .font(.callout)
                            .opacity(0.9)
                            .padding(.top, 5)
                            .foregroundStyle(colorScheme == .light ? .gray : .green.opacity(0.5))
                            .shimmer()
                    } else if let lastSeen = user.lastSeen {
                        Text("Last seen \(lastSeen.relativeFormat())")
                            .fontWidth(.expanded)
                            .font(.callout)
                            .opacity(0.5)
                            .padding(.top,5)
                    } else {
                        Text("Offline")
                            .fontWidth(.expanded)
                            .font(.callout)
                            .opacity(0.5)
                            .padding(.top,5)
                    }
                      
                    
                    
//                    Button {
//
//                    } label: {
//                        ZStack {
//
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.black)
//                                .frame(width: .infinity, height: 40)
//                            Text("Added ✅")
//                                .fontWidth(.expanded)
//                                .foregroundStyle(.white)
//                        }
//                    }
                    
                    
                    VStack {
                        HStack {
                            Text("Overview")
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .font(.title3)
                                .padding(.leading, 5)
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                
                                // card
                                FriendStatWidgetView(icon: "🔥", value: String(socialVM.friendStats?.dayStreak ?? 0), label: "Day Streak")
                                
                                FriendStatWidgetView(icon: "👨‍🎓", value: String(socialVM.friendStats?.xp ?? 0), label: "XP Level")
                            }
                            
                            HStack {
                                FriendStatWidgetView(icon: "⏱️", value: formatHoursMinutes(from: socialVM.friendSecondsStudiedToday), label: "Today")
                                FriendStatWidgetView(icon: "🏆", value: "\(String(format: "%.1f", socialVM.totalHoursStudied))h", label: "Total Hours")
                            }
                        }
                    }
                    .padding(.top, 15)
                }
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 23)
        }
        .onAppear {
            Task {
                await socialVM.loadFriendStats(for: user.userId)
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                UserSettingsView(settingsVM: settingsVM, userVM: profileVM, isUserLoggedIn: $isUserLoggedIn)
            }
        }
        
    }
}

#Preview {
    UserProfileFullSheetView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore", isOnline: true), socialVM: SocialViewModel(), profileVM: ProfileViewModel(), isUserLoggedIn: .constant(true))
}

