//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  AddFriendView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/11/25.
//

import SwiftUI

struct AddFriendView: View {
    @Binding var showingAddFriendSheet: Bool
    @State private var username: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @ObservedObject var viewModel: SocialViewModel
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Add Friends")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        showingAddFriendSheet = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.red)
                           
                    }
                }
               
            }
            .fontWidth(.expanded)
            .padding(.horizontal, 23)
            .padding(.top, 20)
            
            // text field
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("Search for friends", text: $username)
                        .focused($isTextFieldFocused)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 12)
                .padding(.leading, 23)
                .padding(.trailing, isTextFieldFocused ? 12 : 23)
                .frame(height: 36)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)

                if isTextFieldFocused {
                    Button("Cancel") {
                        withAnimation {
                            isTextFieldFocused = false
                            username = ""
                            viewModel.searchResults = []
                        }
                    }
                    .foregroundStyle(.black)
                    .padding(.leading, 10)
                    .padding(.trailing, 23)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 13)
            .padding(.top, 12)
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            
            if isTextFieldFocused {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.searchResults, id: \.userId) { user in
                            UserAddCardView(user: user, viewModel: viewModel)
                        }
                    }
                    .padding(.top, 15)
                }
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            } else {
                
                VStack {
                    HStack {
                        Text("Pending requests")
                            .fontWidth(.expanded)
                    }
                    .padding(.horizontal, 20)
                    ScrollView {
                        VStack(spacing: 16) {
                            // pending friends
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            }
            
           
            
        }
        .onChange(of: username) { oldValue, newValue in
            if !newValue.isEmpty {
                Task {
                    try? await viewModel.loadUsersByUsername(username: newValue)
                }
            } else {
                // Optionally clear results if desired:
                viewModel.searchResults = []
            }
        }
    }
}

#Preview {
    AddFriendView(showingAddFriendSheet: .constant(true), viewModel: SocialViewModel())
}
