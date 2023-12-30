//
//  MessageHandler.swift
//  rainbow-dairy
//
//  Created by Janus Wing on 2023/12/14.
//

import Foundation

// MessageSender.swift

protocol MessageSender {
    func sendMessage(_ message: String)
}

protocol VoiceTranscribe {
    func transcribeVoice(_ voiceData: Data, completion: @escaping (String?, Error?) -> Void)
}
