//
//  GameSettings.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import Foundation

struct GameSettings: Codable, Equatable {
    static let gameTimeRange = 15...120
    static let maxBubblesRange = 5...20

    let gameTime: Int
    let maxBubbles: Int

    init(gameTime: Int = 60, maxBubbles: Int = 15) {
        self.gameTime = min(max(gameTime, Self.gameTimeRange.lowerBound), Self.gameTimeRange.upperBound)
        self.maxBubbles = min(max(maxBubbles, Self.maxBubblesRange.lowerBound), Self.maxBubblesRange.upperBound)
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime, maxBubbles
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(gameTime: try values.decode(Int.self, forKey: .gameTime),
                  maxBubbles: try values.decode(Int.self, forKey: .maxBubbles))
    }
}