//
//  LaunchVideoView.swift
//  FitPalz!
//
//  Created by Joel Urena on 5/23/25.
//

import SwiftUI
import AVKit

/// Plays a bundled MP4 full‑screen and calls `onFinished` after 2.8 s
struct LaunchVideoView: View {
    let onFinished: () -> Void
    private let player: AVPlayer
    
    @State private var isReady = false
    
    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
        let url = Bundle.main.url(forResource: "intro", withExtension: "mp4")!
        self.player = AVPlayer(url: url)
        self.player.isMuted = false       // set true if you want silent splash
    }
    
    var body: some View {
        ZStack {
            // Dark backing color removes black letter‑boxing
            Color(hex: "191919")
                .ignoresSafeArea()
            
            // Intro video
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .opacity(isReady ? 1 : 0)     // quick fade‑in
                .accessibilityHidden(true)    // VO skips the splash
        }
        .onAppear {
            player.play()
            
            // Fade‑in once the player starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { isReady = true }
            }
            
            // Auto‑dismiss after 2.8 s (clip length)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                player.pause()
                onFinished()
            }
        }
    }
}
