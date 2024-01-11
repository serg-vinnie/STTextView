//
//  TestView.swift
//  TextEdit.SwiftUI
//
//  Created by loki on 12.01.2024.
//

import Foundation
import SwiftUI
import STTextViewUI

struct TestView : View {
    @State private var text: AttributedString = AttributedString(NSMutableAttributedString(string: text1).format(with: defaultAttributes))
    @State private var selection: NSRange?
    
    var body: some View {
        STTextViewUI.TextView(
            text: $text,
            selection: $selection,
            options: [])
        { idx in
            NSMutableAttributedString(string: "\(idx)")
                .format(with: defaultAttributes)
        }
        .textViewFont(.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular))
        .frame(height: CGFloat(text1.split(separator: "\n").count) * 16)
    }
}

public extension NSMutableAttributedString {
    private func format(range: Range<Int>, with attributes: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        if range.lowerBound == range.upperBound || range.upperBound > string.count {
            return self
        }
        
        addAttributes( attributes, range: NSRange(range) )
        return self
    }
    
    func format(with attributes: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let range = Range<Int>(uncheckedBounds: (0, string.count))
        return format(range: range, with: attributes)
    }
}

let defaultAttributes = [NSAttributedString.Key.foregroundColor: NSColor(red: 1, green: 1, blue: 1, alpha: 1), NSAttributedString.Key.font: NSFont(name: "Menlo Regular", size: 12.0)!]
 
