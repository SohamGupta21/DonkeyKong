//
//  ContentView.swift
//  DonkeyKong
//
//  Created by soham gupta on 1/18/22.
//

import SwiftUI
import SpriteKit
import AVKit

struct ContentView: View {
    let colors: [Color] = [Color.red, Color.black]
    @State private var isGameSceneShowing = false
    @State var barrelTimerSlider : Double = 5
    @State var marioSpeedSlider : Double = 2
    @State var audioPlayer: AVAudioPlayer!

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Donkey Kong")
                    .font(.custom("Chalkduster", size: 30))
                    .foregroundColor(.red)
                HStack {
                    Image("dk1")
                        .resizable()
                        .frame(width: 64, height: 64)
                    
                    Image("marioL1")
                        .resizable()
                        .frame(width: 64, height: 64)
                    
                    Image("princess1")
                        .resizable()
                        .frame(width: 64, height: 64)
                } // HStack
                Text("Barrels Interval:")
                    .font(.custom("Chalkduster", size: 15))
                    .foregroundColor(.red)
                Slider(value: $barrelTimerSlider, in: 0...20)
                    .frame(width: 250)
                    .accentColor(.red)
                
                Text("Mario Speed:")
                    .font(.custom("Chalkduster", size: 15))
                    .foregroundColor(.red)
                Slider(value: $marioSpeedSlider, in: 0...10)
                    .frame(width: 250)
                    .accentColor(.red)
                Button(action: {
                    SettingsClass.shared.barrelTimer = self.barrelTimerSlider
                    SettingsClass.shared.marioSpeed = self.marioSpeedSlider
                    isGameSceneShowing.toggle()
                }) {
                    Text("Start Game")
                        .font(.custom("Chalkduster", size: 30))
                        .foregroundColor(.red)
                }

            } // Stack
            .fullScreenCover(isPresented: $isGameSceneShowing) {
                GameView(isGameSceneShowing: $isGameSceneShowing)
                    .ignoresSafeArea()
            }
            
        }
        .onAppear {
            let sound = Bundle.main.path(forResource: "119 Mill Fever", ofType: "mp3")
            
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
            
            self.audioPlayer.play()

        }
      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
