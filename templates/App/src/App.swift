import SwiftUI

@main
struct @@PACKAGENAME@@: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Usually this would be in ContentView.swift but I can't seem to get vscode to recognise cross-file classes, so until then I'll be placing all my code in a single file lmao
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}