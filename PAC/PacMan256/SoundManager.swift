//
//  SoundManager.swift
//  PacMan256
//
//  Created for Pac-Man 256 iOS/iPadOS Xcode Project.
//  Uses AVFoundation to play sound effects and retro chiptunes.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var isMuted = false
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var synthEngine: AVAudioEngine?
    private var synthNode: AVAudioSourceNode?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    func setMute(_ mute: Bool) {
        self.isMuted = mute
        if mute {
            audioPlayers.values.forEach { $0.volume = 0.0 }
        } else {
            audioPlayers.values.forEach { $0.volume = 1.0 }
        }
    }
    
    func toggleMute() -> Bool {
        setMute(!isMuted)
        return isMuted
    }
    
    // Play a retro arcade beep
    func playBeep(frequency: Float = 440, duration: Double = 0.08, type: Int = 0) {
        guard !isMuted else { return }
        
        let engine = AVAudioEngine()
        let toneNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buffer = abl[0]
            let pointer = buffer.mData?.assumingMemoryBound(to: Float.self)
            
            let sampleRate: Float = 44100.0
            var sampleIndex: Double = 0
            
            for frame in 0..<Int(frameCount) {
                let percent = Double(frame) / Double(frameCount)
                let envelope = sin(percent * Double.pi) // standard bell envelope
                
                var signal: Float = 0
                let time = sampleIndex / Double(sampleRate)
                let angle = 2.0 * Double.pi * Double(frequency) * time
                
                if type == 0 {
                    // Square wave for chiptune retro bite
                    signal = sin(angle) >= 0 ? 0.15 : -0.15
                } else if type == 1 {
                    // Triangle wave
                    signal = Float(abs(fmod(angle / Double.pi, 2.0) - 1.0) * 0.3 - 0.15)
                } else {
                    // Sine wave
                    signal = Float(sin(angle) * 0.2)
                }
                
                pointer?[frame] = signal * Float(envelope)
                sampleIndex += 1
            }
            return noErr
        }
        
        engine.attach(toneNode)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
        engine.connect(toneNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            // Stop engine after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                engine.stop()
            }
        } catch {
            print("Tone synth failed: \(error)")
        }
    }
    
    func playChomp() {
        playBeep(frequency: 330, duration: 0.06, type: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.playBeep(frequency: 220, duration: 0.06, type: 0)
        }
    }
    
    func playCoin() {
        playBeep(frequency: 880, duration: 0.08, type: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playBeep(frequency: 1320, duration: 0.14, type: 1)
        }
    }
    
    func playPowerPellet() {
        playBeep(frequency: 600, duration: 0.1, type: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playBeep(frequency: 800, duration: 0.1, type: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.playBeep(frequency: 1000, duration: 0.2, type: 0)
            }
        }
    }
    
    func playLaser() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.04) {
                let freq = 1200 - (i * 150)
                self.playBeep(frequency: Float(freq), duration: 0.04, type: 0)
            }
        }
    }
    
    func playExplosion() {
        // High intensity deep crackle for weapons
        for i in 0..<12 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                let freq = Int.random(in: 60...180)
                self.playBeep(frequency: Float(freq), duration: 0.03, type: 0)
            }
        }
    }
    
    func playDeath() {
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                let freq = 440 - (i * 35)
                self.playBeep(frequency: Float(freq), duration: 0.07, type: 0)
            }
        }
    }
}
