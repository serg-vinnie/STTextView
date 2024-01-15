//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import SwiftUI
import STTextView

/// This SwiftUI view can be used to view and edit rich text.
public struct TextView: SwiftUI.View {

    @frozen
    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Breaks the text as needed to fit within the bounding box.
        public static let wrapLines = Options(rawValue: 1 << 0)

        /// Highlighted selected line
        public static let highlightSelectedLine = Options(rawValue: 1 << 1)
    }

    @Environment(\.colorScheme) private var colorScheme
    @Binding private var text: AttributedString
    @Binding private var selection: NSRange?
    private let options: Options
    private let plugins: [any STPlugin]
    let numMapper: ((Int)->NSAttributedString)?

    /// Create a text edit view with a certain text that uses a certain options.
    /// - Parameters:
    ///   - text: The attributed string content
    ///   - options: Editor options
    ///   - plugins: Editor plugins
    public init(
        text: Binding<AttributedString>,
        selection: Binding<NSRange?> = .constant(nil),
        options: Options = [],
        plugins: [any STPlugin] = [],
        numMapper: ((Int)->NSAttributedString)?
    ) {
        _text = text
        _selection = selection
        self.options = options
        self.plugins = plugins
        self.numMapper = numMapper
    }

    public var body: some View {
        TextViewRepresentable(
            text: $text,
            selection: $selection,
            options: options,
            plugins: plugins,
            numMapper: numMapper
        )
//        .background(.background)
    }
}

private struct TextViewRepresentable: NSViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.font) private var font
    @Environment(\.lineSpacing) private var lineSpacing

    @Binding private var text: AttributedString
    @Binding private var selection: NSRange?
    private let options: TextView.Options
    private var plugins: [any STPlugin]
    let numMapper: ((Int)->NSAttributedString)?

    init(text: Binding<AttributedString>, selection: Binding<NSRange?>, options: TextView.Options, plugins: [any STPlugin] = [], numMapper: ((Int)->NSAttributedString)?) {
        self._text = text
        self._selection = selection
        self.options = options
        self.plugins = plugins
        self.numMapper = numMapper
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = STTextView.scrollableTextView(numMapper: numMapper)
        let textView = scrollView.documentView as! STTextView
        textView.delegate = context.coordinator
        textView.highlightSelectedLine = options.contains(.highlightSelectedLine)
        textView.widthTracksTextView = options.contains(.wrapLines)
        textView.setSelectedRange(NSRange())
        textView.isSelectable = true
        textView.isEditable = false

        context.coordinator.isUpdating = true
        textView.setAttributedString(NSAttributedString(styledAttributedString(textView.typingAttributes)))
        context.coordinator.isUpdating = false

        for plugin in plugins {
            textView.addPlugin(plugin)
        }
        
        DispatchQueue.main.async {
            scrollView.documentView?.scrollToVisible(.zero)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        let textView = scrollView.documentView as! STTextView

        do {
            context.coordinator.isUpdating = true
            if context.coordinator.isDidChangeText == false {
                textView.setAttributedString(NSAttributedString(styledAttributedString(textView.typingAttributes)))
            }
            context.coordinator.isUpdating = false
            context.coordinator.isDidChangeText = false
        }

        if textView.selectedRange() != selection, let selection {
            textView.setSelectedRange(selection)
        }

//        if textView.isEditable != isEnabled {
//            textView.isEditable = isEnabled
//        }
//
//        if textView.isSelectable != isEnabled {
//            textView.isSelectable = isEnabled
//        }

        let wrapLines = options.contains(.wrapLines)
        if wrapLines != textView.widthTracksTextView {
            textView.widthTracksTextView = options.contains(.wrapLines)
        }

        if textView.font != font {
            textView.font = font
        }
    }

    func makeCoordinator() -> TextCoordinator {
        TextCoordinator(parent: self)
    }

    private func styledAttributedString(_ typingAttributes: [NSAttributedString.Key: Any]) -> AttributedString {
        let paragraph = (typingAttributes[.paragraphStyle] as! NSParagraphStyle).mutableCopy() as! NSMutableParagraphStyle
        if paragraph.lineSpacing != lineSpacing {
            paragraph.lineSpacing = lineSpacing
            var typingAttributes = typingAttributes
            typingAttributes[.paragraphStyle] = paragraph

            let attributeContainer = AttributeContainer(typingAttributes)
            var styledText = text
            styledText.mergeAttributes(attributeContainer, mergePolicy: .keepNew)
            return styledText
        }

        return text
    }

    class TextCoordinator: STTextViewDelegate {
        var parent: TextViewRepresentable
        var isUpdating: Bool = false
        var isDidChangeText: Bool = false
        var enqueuedValue: AttributedString?

        init(parent: TextViewRepresentable) {
            self.parent = parent
        }

        func textViewDidChangeText(_ notification: Notification) {
            guard let textView = notification.object as? STTextView else {
                return
            }

            if !isUpdating {
                let newTextValue = AttributedString(textView.attributedString())
                DispatchQueue.main.async {
                    self.isDidChangeText = true
                    self.parent.text = newTextValue
                }
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? STTextView else {
                return
            }

            Task { @MainActor in
                self.isDidChangeText = true
                self.parent.selection = textView.selectedRange()
            }
        }

    }
}

