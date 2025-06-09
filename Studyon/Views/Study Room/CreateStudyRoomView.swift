//
//  CreateStudyRoomView.swift
//  Studyon
//
//  Created by Daniel Moreno on 6/6/25.
//

import SwiftUI

struct CreateStudyRoomView: View {
    @Binding var showCreateStudyRoom: Bool
    @State private var progress: Double = 0
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
                    
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text("Just you")
                    .fontWeight(.light)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .font(.caption)
                    .fontWidth(.expanded)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Lets go")
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
                    
                    Spacer()
                }
                
                Spacer()
                
                Image(systemName: "person.3.fill")
                  .resizable()
                  .frame(width: 60, height: 30)
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
                    
                } label: {
                    Text("Lets go")
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
        
    }
}

#Preview {
    CreateStudyRoomView(showCreateStudyRoom: .constant(true))
}
