import SwiftUI

//struct ContentView: View {
//    @StateObject var messageSession = MessageMultipeerSession()
//
//    @State private var messageToSend: String = ""
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Connected Devices:")
//            Text(String(describing: messageSession.connectedPeers.map(\.displayName)))
//
//            Divider()
//
//            HStack {
//                // Add text field to input messages
//                TextField("Type your message", text: $messageToSend)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                Button("Send") {
//                    if !messageToSend.isEmpty {
//                        messageSession.send(message: messageToSend)
//                        messageToSend = ""
//                    }
//                }
//                .padding()
//            }
//            Spacer()
//
//            Text("Received Messages:")
//            ScrollView {
//                VStack(alignment: .leading, spacing: 8) {
//                    ForEach(messageSession.receivedMessages, id: \.self) { message in
//                        Text(message)
//                    }
//                }
//                .padding()
//            }
//        }
//        .padding()
//    }
//}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(destination: HostView()) {
                Text("Host View")
            }
            NavigationLink(destination: GuestView()) {
                Text("Guest View")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
