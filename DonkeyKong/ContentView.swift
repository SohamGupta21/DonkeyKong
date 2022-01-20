//
//  ContentView.swift
//  DonkeyKong
//
//  Created by soham gupta on 1/18/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: 750, height: 1335))).ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
