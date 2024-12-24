import SwiftUI

struct DemoView: View {
    @State private var messages: [String] = (1...1000).map { "Message \($0)" }
    
    var body: some View {
        Track(direction: .reverse) { proxy in
            VStack {
                ForEach(messages, id: \.self) { message in
                    MessageView(message: message, proxy: proxy)
                        .id(message)
                    .onTapGesture {
                        proxy.scrollTo(message, alignment: .top, anchor: .top)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    DemoView()
}


struct MessageView: View {
    let message: String
    let proxy: TrackProxy

    var body: some View {
        HStack {
            Text(message)
        }
        .bold()
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)).opacity(0.5))
        .cornerRadius(.infinity)
        .contextMenu {
            Text("Test")
        }
        .track(message)
    }
}
