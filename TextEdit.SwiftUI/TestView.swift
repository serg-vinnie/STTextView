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
    @State private var text: AttributedString = "Short text"
    @State private var selection: NSRange?
    
    var body: some View {
        STTextViewUI.TextView(
            text: $text,
            selection: $selection,
            options: [])
        { idx in
            NSAttributedString(string: "\(idx)")
        }
        .textViewFont(.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular))
    }
}
