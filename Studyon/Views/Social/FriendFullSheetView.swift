//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  FriendFullSheetView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/14/25.
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
    let duration: Double = 1.2
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

extension View {
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}
struct FriendFullSheetView: View {
    let user: DBUser
    @Binding var showFriendSheet: Bool
    @ObservedObject var socialVM: SocialViewModel
    var body: some View {
        ZStack {
            Color.softWhite.ignoresSafeArea()
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
                    
                    Menu {
//                        Button("Report User") {
//                            // report code
//                        }
                        Button("Remove Friend") {
                            Task {
                                await socialVM.unfriend(userId: user.userId)
                                await MainActor.run {
                                    showFriendSheet = false
                                }
                            }
                        }
//                        Button("Block User") {
//                            
//                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                        }
                    }
                    
                    
                }
                VStack(alignment: .center) {
                    ZStack {
                        Image("profile_pic1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(
                                color: (user.isOnline == true ? Color.green : Color.gray).opacity(0.2),
                                radius: 20, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.black, lineWidth: 1.5)
                            )
                        
                        Circle()
                            .fill(user.isOnline == true ? Color.green : Color.gray)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 60)
                            .padding(.top, 60)
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
                            .padding(.top,5)
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
                            .shimmer()
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
        
    }
}


struct FriendStatWidgetView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
                    Text(icon)
                        .font(.system(size: 28))
                        .frame(width: 32, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(value)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    Spacer()
                }
                .fontWidth(.expanded)
                .padding(.leading, 15)
                .frame(width: 170, height: 75)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 10)
    }
        
}

#Preview {
    FriendFullSheetView(user: DBUser(userId: "test", email: "test@example.com", photoUrl: "", fullName: "Daniel M", username: "danmore"), showFriendSheet: .constant(true), socialVM: SocialViewModel())
        
}

