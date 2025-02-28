//
//  Home.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/15/25.
//

import SwiftUI

struct Home: View {
    @State private var activeIntro: PageIntro = pageIntros[0]
    @State private var emailID: String = ""
    @State private var password: String = ""
    //@State private var keyboardHeight: GGFloat = 0
    var body: some View {
        GeometryReader{
            let size = $0.size
            
            IntroView(intro: $activeIntro, size: size) {
                // User Login/Signup View
                VStack(spacing: 10) {
                    // Custom TextField
                    CustomTextField(text: $emailID, hint: "Email Address", leadingIcon: Image(systemName: "envelope"))
                    CustomTextField(text: $emailID, hint: "Password", leadingIcon: Image(systemName: "lock"), isPassword: true)
                    
                    Spacer(minLength: 10)
                    
                    Button {
                        
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background {
                                Capsule()
                                    .fill(.black)
                            }
                        
                    }
                }
                .padding(.top, 25)
            }
        }
        .padding(15)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Intro view
struct IntroView<ActionView: View>: View {
    @Binding var intro: PageIntro
    var size: CGSize
    var actionView: ActionView
    
    init(intro: Binding<PageIntro>, size: CGSize, @ViewBuilder actionView: @escaping () -> ActionView) {
        self._intro = intro
        self.size = size
        self.actionView = actionView()
    }
    
    // Animation properties
    @State private var showView: Bool = false
    @State private var hideWholeView: Bool = false
    
    var body: some View {
        VStack {
            
            // back button
            HStack {
                if intro != pageIntros.first {
                    Button {
                        changeIntro(true)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .contentShape(Rectangle())
                    }

                    .padding(10)
                    // animate
                    .offset(y: showView ? 0 : -200)
                    .offset(y: hideWholeView ? -200 : 0)
                }
                
                Spacer()
            }
            //.background(Color.black)
        
            
            
            HStack {
                Text(intro.title)
                    .font(.title)
                    .fontWidth(.expanded)
                    .fontWeight(.heavy)
                Spacer()
            }
            .padding()
            
            GeometryReader {
                let size = $0.size
                
                
                Image(intro.introAssetImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(30)
                    .frame(width: size.width, height: size.height)
            }
            // move up
            .offset(y: showView ? 0 : -size.height / 2)
            .opacity(showView ? 1 : 0)
            
            Text(intro.subTitile)
                .fontWidth(.expanded)
                .fontWeight(.heavy)
            
            if !intro.displayAction {
                Group {
                    Spacer(minLength: 25)
                    
                    CustomIndicatorView(totalPages: filteredPages.count, currentPage: filteredPages.firstIndex(of: intro) ?? 0, activeTint: .gray)
                    
                    Spacer(minLength: 10)
                    
                    Button {
                        changeIntro()
                    } label: {
                        Text("Next")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: size.width * 0.4)
                            .padding(.vertical,15)
                            .background {
                                Capsule()
                                    .fill(.black)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Action view
                actionView
                    .offset(y: showView ? 0 : size.height / 2)
                    .opacity(showView ? 1 : 0)
            }
            
        } // end of vstack
        .frame(maxWidth: .infinity, alignment: .leading)
        // move down
        .offset(y: showView ? 0 : size.height / 2)
        .opacity(showView ? 1 : 0)
        .offset(y: hideWholeView ? size.height / 2 : 0)
        .opacity(hideWholeView ? 0 : 1)
        

        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                showView = true
            }
        }
    }
    
    
    func changeIntro(_ isPrevious: Bool = false) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            hideWholeView = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = pageIntros.firstIndex(of: intro), (isPrevious ? index != 0 : index != pageIntros.count - 1){
                intro = isPrevious ? pageIntros[index - 1] : pageIntros[index + 1]
            } else {
                intro = isPrevious ? pageIntros[0] : pageIntros[pageIntros.count - 1]
            }
            
            //
            hideWholeView = false
            showView = false
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showView = true
            }
        }
        
       
    }
    
    var filteredPages: [PageIntro] {
        return pageIntros.filter { !$0.displayAction }
    }
}


