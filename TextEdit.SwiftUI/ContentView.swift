//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import SwiftUI
import STTextViewUI
import SwiftUIIntrospect

struct ContentView: View {
    @State private var text: AttributedString = ""
    @State private var selection: NSRange?
    @State private var counter = 0
    var scrollObserver = ScrollViewObserver()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                TestView()
                TestView()
                TestView()
            }
            .introspect(.scrollView, on: .macOS(.v12, .v13, .v14) ) {
                scrollObserver.subscribe(to: $0)
            }

            // Button("Modify") {
            //     text.insert(AttributedString("\(counter)\n"), at: text.startIndex)
            //     counter += 1
            //      selection = NSRange(location: 0, length: 3)
            // }

            // SwiftUI is slow, I wouldn't use it
            //
            // SwiftUI.TextEditor(text: Binding(get: { String(text.characters) }, set: { text = AttributedString($0) }))
            //    .font(.body)

            HStack {
                if let selection {
                    Text("Location: \(selection.location)")
                } else {
                    Text("No selection")
                }

                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
//        .onAppear {
//            loadContent()
//        }
    }

    private func loadContent() {
        let string = try! String(contentsOf: Bundle.main.url(forResource: "content", withExtension: "txt")!)
        self.text = AttributedString(string, attributes: AttributeContainer().foregroundColor(NSColor.textColor))
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

let text1 = """
As we have seen, Machiavelli had been shocked to discover, at the time of the 1500 débâcle, 
that the French regarded the Florentines with derision because of their military incompetence,
and especially because of their inability to reduce Pisa to obedience.
After the renewed failure of 1505, 
he took the matter into his own hands and drew up a detailed plan for the replacement of Florence’s hired troops with a citizen militia.
The great council provisionally accepted the idea in December 1505, 
and Machiavelli was authorized to begin recruiting.
By the following February he was ready to hold his first parade in the city, 
an occasion watched with great admiration by the diarist Luca Landucci,
who recorded that ‘this was thought the finest thing that had ever been arranged for Florence’.
During the summer of 1506 Machiavelli wrote A Provision for Infantry, 
emphasizing ‘how little hope it is possible to place in foreign and hired arms’,
and arguing that the city ought instead to be ‘armed with her own weapons and with her own men’.
By the end of the year, the great council was finally convinced. 
A new government committee – the Nine of the Militia – was set up,
Machiavelli was elected its secretary,
and one of the most cherished ideals of Florentine humanism became a reality.
"""
