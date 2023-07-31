//
//  GuestView.swift
//  Multipeer Connectivity
//
//  Created by Jefry Gunawan on 29/07/23.
//

import SwiftUI
import MultipeerConnectivity

struct GuestView: View {
    @StateObject var messageSession = MessageMultipeerSession()
    
//    @State private var selectedHost: MCPeerID? = nil
    
    @State private var messageToSend: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
//            // List of available hosts
//            if $messageSession.discoveredHosts.isEmpty {
//                Text("No hosts found")
//            } else {
//                List(messageSession.discoveredHosts, id: \.self) { host in
//                    Button(action: {
//                        messageSession.connectToHost(host)
//                    }) {
//                        Text(host.displayName)
//                    }
//                }
//                .listStyle(PlainListStyle())
//            }
            
            Text("Connected Devices:")
            Text(String(describing: messageSession.connectedPeers.map(\.displayName)))
            
            Divider()
            
            HStack {
                // Add text field to input messages
                TextField("Type your message", text: $messageToSend)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Send") {
                    if !messageToSend.isEmpty {
                        messageSession.send(message: messageToSend)
                        messageToSend = ""
                    }
                }
                .padding()
            }
            Spacer()
            
            Text("Received Messages:")
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    //                    ForEach(messageSession.receivedMessages, id: \.self) { message in
                    //                        Text(message)
                    //                    }
                    Text(messageSession.receivedMessages)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct GuestView_Previews: PreviewProvider {
    static var previews: some View {
        GuestView()
    }
}
