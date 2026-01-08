//
//  RichTextEditorSheet.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/12/25.
//

import SwiftUI
import UIKit

// MARK: - RichTextView
struct RichTextView: UIViewRepresentable {

    @Binding var attributedText: NSAttributedString
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderline: Bool
    @Binding var isStrikethrough: Bool
    @Binding var isBullet: Bool
    @Binding var isNumbered: Bool
    
    @Binding var textViewRef: UITextView? // <-- reference for immediate update

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.keyboardDismissMode = .interactive
        textView.autocapitalizationType = .sentences
        
        DispatchQueue.main.async {
            self.textViewRef = textView
        }
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {

        let parent: RichTextView

        init(_ parent: RichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            updateToolbar(textView)
            applyTypingStyle(textView)
        }

        private func updateToolbar(_ textView: UITextView) {
            let attrs = textView.typingAttributes
            if let font = attrs[.font] as? UIFont {
                parent.isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                parent.isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
            parent.isUnderline = (attrs[.underlineStyle] as? Int ?? 0) > 0
            parent.isStrikethrough = (attrs[.strikethroughStyle] as? Int ?? 0) > 0
        }

        func applyTypingStyle(_ textView: UITextView) {

            var traits: UIFontDescriptor.SymbolicTraits = []
            if parent.isBold { traits.insert(.traitBold) }
            if parent.isItalic { traits.insert(.traitItalic) }

            let baseFont = UIFont.systemFont(ofSize: 16)
            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) ?? baseFont.fontDescriptor
            let font = UIFont(descriptor: descriptor, size: 16)

            var attributes: [NSAttributedString.Key: Any] = [.font: font]

            if parent.isUnderline { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue }
            if parent.isStrikethrough { attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }

            if parent.isBullet || parent.isNumbered {
                let paragraph = NSMutableParagraphStyle()
                paragraph.headIndent = 15
                paragraph.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
                paragraph.paragraphSpacing = 2
                attributes[.paragraphStyle] = paragraph
            }

            textView.typingAttributes = attributes
        }
        
        // MARK: Apply immediately on toolbar tap
        func applyTypingStyleImmediately() {
            guard let textView = parent.textViewRef else { return }
            applyTypingStyle(textView)
        }
        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {

            // Detect Enter key
            if text == "\n" {

                // Get current line
                if let currentLineRange = textView.currentLineRange() {
                    let currentLine = textView.text[currentLineRange]

                    var newLinePrefix = ""

                    if parent.isBullet {
                        newLinePrefix = "• "
                    } else if parent.isNumbered {
                        // Count previous lines for numbering
                        let lines = textView.text.components(separatedBy: "\n")
                        let lastNumber = lines.count
                        newLinePrefix = "\(lastNumber + 1). "
                    }

                    // Insert newline + prefix
                    let cursorPosition = range.location
                    let nsText = NSMutableString(string: textView.text)
                    nsText.insert("\n" + newLinePrefix, at: cursorPosition)
                    textView.text = nsText as String

                    // Move cursor to end of inserted prefix
                    if let newPosition = textView.position(from: textView.beginningOfDocument,
                                                           offset: cursorPosition + 1 + newLinePrefix.count) {
                        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    }

                    // Update attributed text and apply typing style
                    parent.attributedText = textView.attributedText
                    applyTypingStyle(textView)

                    return false
                }
            }

            return true
        }

    }
}

// MARK: - RichTextEditorSheet
struct RichTextEditorSheet: View {

    @State private var attributedText = NSAttributedString(string: "")
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    @State private var isStrikethrough = false
    @State private var isBullet = false
    @State private var isNumbered = false
    
    @State private var textViewRef: UITextView? // <-- UITextView reference

    var onSave: (NSAttributedString) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Text("Show Notes")
                    .font(.headline)
                Spacer()
                Button("Save") { onSave(attributedText) }
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))

            Divider()

            // Toolbar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    formattingButton("B", isBold) {
                        isBold.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    .bold()
                    formattingButton("I", isItalic) {
                        isItalic.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    .italic()
                    formattingButton("U", isUnderline) {
                        isUnderline.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    formattingButton("S", isStrikethrough) {
                        isStrikethrough.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }

                    Divider().frame(height: 30)

                    formattingButton("•", isBullet) {
                        isBullet.toggle()
                        isNumbered = false
                        textViewRef?.applyBulletList()
                    }
                    formattingButton("1.", isNumbered) {
                        isNumbered.toggle()
                        isBullet = false
                        textViewRef?.applyNumberedList()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .frame(height: 50)

            Divider()

            // Editor
            RichTextView(
                attributedText: $attributedText,
                isBold: $isBold,
                isItalic: $isItalic,
                isUnderline: $isUnderline,
                isStrikethrough: $isStrikethrough,
                isBullet: $isBullet,
                isNumbered: $isNumbered,
                textViewRef: $textViewRef
            )
            .padding()
            .background(Color.white)

            Spacer()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func formattingButton(_ title: String, _ active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(width: 36, height: 36)
                .background(active ? Color.defaultTheme : Color.clear)
                .foregroundColor(active ? .white : .black)
                .cornerRadius(6)
                .animation(.easeInOut, value: active)
        }
    }

    private func toggleBullet() {
        isBullet.toggle()
        if isBullet { isNumbered = false }
    }

    private func toggleNumbered() {
        isNumbered.toggle()
        if isNumbered { isBullet = false }
    }
}

// MARK: NSAttributedString HTML Conversion
extension NSAttributedString {
    func toHTML() -> String {
        let data = try? data(from: NSRange(location: 0, length: length),
                             documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
        return String(data: data ?? Data(), encoding: .utf8) ?? ""
    }
}

// MARK: UITextView Helper
extension UITextView {
    func applyCurrentStylesImmediately() {
        if let coordinator = self.delegate as? RichTextView.Coordinator {
            coordinator.applyTypingStyleImmediately()
        }
    }
}
extension UITextView {
    func currentLineRange() -> Range<String.Index>? {
        guard let selectedRange = self.selectedTextRange else { return nil }
        let cursorPosition = offset(from: beginningOfDocument, to: selectedRange.start)
        let textNSString = self.text as NSString
        let lines = textNSString.components(separatedBy: "\n")

        var count = 0
        for line in lines {
            let start = count
            let end = count + line.count
            if cursorPosition >= start && cursorPosition <= end {
                if let startIndex = self.text.index(self.text.startIndex, offsetBy: start, limitedBy: self.text.endIndex),
                   let endIndex = self.text.index(self.text.startIndex, offsetBy: end, limitedBy: self.text.endIndex) {
                    return startIndex..<endIndex
                }
            }
            count = end + 1 // +1 for \n
        }
        return nil
    }
}
extension UITextView {

    func applyBulletList() {
        let range = selectedRange

        let textList = NSTextList(
            markerFormat: .disc,
            options: 0
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.textLists = [textList]
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacing = 6

        textStorage.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range.length == 0
                ? NSRange(location: range.location, length: 1)
                : range
        )
    }
}
extension UITextView {

    func applyNumberedList() {
        let range = selectedRange

        let textList = NSTextList(
            markerFormat: .decimal,
            options: 0
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.textLists = [textList]
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacing = 6

        textStorage.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range.length == 0
                ? NSRange(location: range.location, length: 1)
                : range
        )
    }
}
