//
//  ContentView.swift
//  stickers
//
//  Created by Rodrigo Araujo on 08/11/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        PackListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [StickerPack.self, Sticker.self], inMemory: true)
}
