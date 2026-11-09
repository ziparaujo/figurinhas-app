//
//  stickersApp.swift
//  stickers
//
//  Created by Rodrigo Araujo on 08/11/26.
//

import SwiftUI
import SwiftData

@main
struct stickersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [StickerPack.self, Sticker.self])
    }
}
