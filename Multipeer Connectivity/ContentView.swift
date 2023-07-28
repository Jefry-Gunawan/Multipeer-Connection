import MultipeerConnectivity
import os
import SwiftUI

struct ContentView: View {
    @StateObject var messageSession = MessageMultipeerSession()

    @State private var messageToSend: String = ""

    var body: some View {
        VStack(alignment: .leading) {
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
                    ForEach(messageSession.receivedMessages, id: \.self) { message in
                        Text(message)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

class MessageMultipeerSession: NSObject, ObservableObject {
    private let serviceType = "example-message"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let log = Logger()

    @Published var connectedPeers: [MCPeerID] = []
    @Published var receivedMessages: [String] = []

    override init() {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }

    func send(message: String) {
        log.info("Sending message: \(message) to \(self.session.connectedPeers.count) peers")

        if !session.connectedPeers.isEmpty {
            do {
                try session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error sending message: \(error)")
            }
        }
    }
}

extension MessageMultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension MessageMultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
    }
}

extension MessageMultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            log.info("Received message: \(message)")
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }
        } else {
            log.info("Received invalid value \(data.count) bytes")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
            // Handle incoming streams if needed
        }

        func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
            // Handle incoming resources if needed
        }

        func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
            // Handle finished receiving resources if needed
        }
}
