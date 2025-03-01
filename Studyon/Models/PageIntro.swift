//
//  PageIntro.swift
//  Studyon
//
//  Created by Daniel Moreno on 2/15/25.
//

import Foundation

struct PageIntro: Identifiable, Hashable {
    var id: UUID = .init()
    var introAssetImage: String
    var title: String
    var subTitile: String
    var displayAction: Bool = false
}

var pageIntros: [PageIntro] = [
    .init(introAssetImage: "intro_image_1", title: "Welcome to Studyon!", subTitile: "Ready to Study?"),
    .init(introAssetImage: "intro_image_2", title: "Features", subTitile: "Study with your friends!"),
    .init(introAssetImage: "intro_action_1", title: "Let's Get Started", subTitile: "Sign up using your email!", displayAction: true)
]
