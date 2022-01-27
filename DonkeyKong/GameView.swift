//
//  GameView.swift
//  DonkeyKong
//
//  Created by soham gupta on 1/26/22.
//


import SwiftUI
import SpriteKit
struct GameView: View {
    @Binding var isGameSceneShowing: Bool
    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: 750, height: 1335)))
            .overlay(Button(action: {
                print("click")
                isGameSceneShowing = false
            }) {
                Text("Home")
                    .font(.custom("Chalkduster", size: 20))
                    .foregroundColor(.red)
                    .padding()
            }, alignment: .bottomTrailing)
    }
}

//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView()
//    }
//}
