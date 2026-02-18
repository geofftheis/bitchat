// _HalfWitStubs.swift
//
// Stub implementations for symbols defined in files excluded by BitchatSDK's
// Package.swift. These files are excluded because they contain @main (BitchatApp.swift)
// or are UI-only (Views/MessageTextHelpers.swift), but other compiled Bitchat
// services reference their symbols.
//
// Previously injected at CI build time; now committed directly in the fork.
// See BITCHAT_PATCHES.md — "Stubs for Excluded Symbols".

import Foundation

enum BitchatApp {
    static let bundleID = Bundle.main.bundleIdentifier ?? "chat.bitchat"
    static let groupID = "group.\(bundleID)"
}

extension String {
    func hasVeryLongToken(threshold: Int) -> Bool {
        self.split(separator: " ").contains { $0.count >= threshold }
    }
}
