//
//  LottieView.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-05-02.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: "meditate")
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        return animationView
    }
    
    func updateUIView(_ uiView: Lottie.LottieAnimationView, context: Context) {
        
    }
}
