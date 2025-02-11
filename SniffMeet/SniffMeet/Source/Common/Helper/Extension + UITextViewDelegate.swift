//
//  Extension + UITextViewDelegate.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import UIKit

extension UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView, placeholder: String, textViewEdited: inout Bool) {
        if textView.text == placeholder {
            textView.text = nil
            textView.textColor = .black
            textViewEdited = true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView, placeholder: String) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }

    func shouldChangeText(_ textView: UITextView, range: NSRange, replacementText text: String, limit: Int) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text,
              let newRange = Range(range, in: oldString) else {
            return true
        }
        let newString = oldString.replacingCharacters(
            in: newRange,
            with: inputString
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        let characterCount = newString.count
        return characterCount <= limit
    }
}
