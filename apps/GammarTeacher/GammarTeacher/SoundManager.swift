//
//  SoundManager.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//


import AppKit

class SoundManager {
    static let shared = SoundManager()
    
    func playSuccess() {
        NSSound(named: "Glass")?.play() // 清脆的成功音
    }
    
    func playError() {
        NSSound(named: "Basso")?.play() // 低沉的错误音
    }
    
    func playTyping() {
        // 可选：给罚写增加一点机械键盘的打字音效，暂时留空
    }
}