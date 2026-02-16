import Foundation

// RelayDecision encapsulates a single relay scheduling choice.
struct RelayDecision {
    let shouldRelay: Bool
    let newTTL: UInt8
    let delayMs: Int
}

// RelayController centralizes flood control policy for relays.
struct RelayController {
    static func decide(ttl: UInt8,
                       senderIsSelf: Bool,
                       isEncrypted: Bool,
                       isDirectedEncrypted: Bool,
                       isFragment: Bool,
                       isDirectedFragment: Bool,
                       isHandshake: Bool,
                       isAnnounce: Bool,
                       degree: Int,
                       highDegreeThreshold: Int) -> RelayDecision {
        let ttlCap = min(ttl, TransportConfig.messageTTLDefault)

        // Suppress obvious non-relays
        if ttlCap <= 1 || senderIsSelf {
            return RelayDecision(shouldRelay: false, newTTL: ttlCap, delayMs: 0)
        }

        // For session-critical or directed traffic, be deterministic and reliable
        if isHandshake || isDirectedFragment || isDirectedEncrypted {
            // Always relay with no TTL cap for these types
            let newTTL = ttlCap &- 1
            // Half-Wit: zero relay jitter for real-time gaming — see BITCHAT_PATCHES.md Patch 6
            let delayMs = 0
            return RelayDecision(shouldRelay: true, newTTL: newTTL, delayMs: delayMs)
        }

        if isFragment {
            let ttlLimit = min(ttlCap, TransportConfig.bleFragmentRelayTtlCap)
            guard ttlLimit > 1 else {
                return RelayDecision(shouldRelay: false, newTTL: ttlLimit, delayMs: 0)
            }
            let newTTL = ttlLimit &- 1
            let delayMs = 0  // Half-Wit: zero relay jitter — see BITCHAT_PATCHES.md Patch 6
            return RelayDecision(shouldRelay: true, newTTL: newTTL, delayMs: delayMs)
        }

        // TTL clamping for broadcast
        // - Dense graphs: keep lower but still allow multi-hop bridging
        // - Announces get a bit more headroom
        let ttlLimit: UInt8 = {
            if degree >= highDegreeThreshold {
                return max(UInt8(2), min(ttlCap, UInt8(5)))
            }
            let preferred = UInt8(isAnnounce ? 7 : 6)
            return max(UInt8(2), min(ttlCap, preferred))
        }()
        let newTTL = ttlLimit &- 1

        // Half-Wit: zero relay jitter for real-time gaming — see BITCHAT_PATCHES.md Patch 6
        let delayMs = 0
        return RelayDecision(shouldRelay: true, newTTL: newTTL, delayMs: delayMs)
    }
}
