//
//  InputBarAccessoryViewDelegate.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        let hideMicButton = !text.isEmpty
        updateMickButtonState(hideMicButton)
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let hasText = !inputBar.inputTextView.components
            .compactMap { $0 as? String }
            .filter { $0 == text }
            .isEmpty

        if hasText {
            messageSend(text: text,
                        image: nil,
                        video: nil,
                        audio: nil,
                        location: nil,
                        audioDuration: nil)
        }

        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
