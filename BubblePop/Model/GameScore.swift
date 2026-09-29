import UIKit

struct GameScore {
    private static let comboMultiplier = 1.5

    private(set) var total = 0
    private(set) var highScore: Int
    private var lastColor: UIColor?

    init(highScore: Int = 0) {
        self.highScore = max(highScore, 0)
    }

    mutating func record(_ bubble: BubbleModel) {
        let points = bubble.color == lastColor
            ? Int(Double(bubble.point) * Self.comboMultiplier)
            : bubble.point
        total += points
        highScore = max(highScore, total)
        lastColor = bubble.color
    }
}