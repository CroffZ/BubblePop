//
//  GameViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import UIKit
import GameKit

class GameViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var bubblesView: UIView!

    private let randomSource: GKRandomSource = GKARC4RandomSource()
    private let dataStorage = DataStorage()
    private let comboMultiplier = 1.5
    private let removalChance: Float = 0.7
    private let spawnChance: Float = 0.5

    var player: String?
    var settings: GameSettings?
    private var timer: Timer?
    private var timeLeft: Int = 60
    private var finished = false
    private var lastColor: UIColor?
    private var score: Int = 0
    private var records: [ScoreRecord] = []
    private var highScore: Int = 0

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            settings = try dataStorage.loadGameSettings()
        } catch {
            settings = GameSettings()
        }

        do {
            records = try dataStorage.loadScoreRecord()
        } catch {
            records = []
        }
        records.sort { $0.score > $1.score }

        if let best = records.first {
            highScore = best.score
            highScoreLabel.text = String(highScore)
        }

        timeLeft = settings?.gameTime ?? GameSettings().gameTime
        timeLabel.text = String(timeLeft)

        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for bubbleView in bubblesView.subviews {
            (bubbleView as? BubbleView)?.disappear()
        }
    }

    @objc private func pauseGame() {
        stopTimer()
    }

    @objc private func resumeGame() {
        guard view.window != nil else { return }
        startTimerIfNeeded()
    }

    private func startTimerIfNeeded() {
        guard timer == nil, !finished else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        updateTimeLabel()
        guard !finished else { return }
        updateBubbles()
    }

    func updateTimeLabel() {
        guard timeLeft > 0 else {
            endGame()
            return
        }
        timeLeft -= 1
        timeLabel.text = "\(timeLeft)"
        if timeLeft == 0 {
            endGame()
        }
    }

    private func endGame() {
        stopTimer()
        guard !finished else { return }
        finished = true

        let player = self.player ?? "Player"
        records.append(ScoreRecord(player: player, score: score))
        records.sort { $0.score > $1.score }
        do {
            try dataStorage.saveData(scores: records)
        } catch {
            print(error)
        }

        let alertController = UIAlertController(title: "Game Over", message: "\(player), your score is \(score)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "See Scores", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "ScoreboardViewSegue", sender: nil)
        })
        present(alertController, animated: true)
    }

    func updateBubbles() {
        for bubbleView in bubblesView.subviews {
            if randomSource.nextUniform() >= removalChance, let bubble = bubbleView as? BubbleView {
                bubble.disappear()
            }
        }

        let spaceLeft = (settings?.maxBubbles ?? GameSettings().maxBubbles) - bubblesView.subviews.count
        guard spaceLeft > 0 else { return }
        for _ in 0..<spaceLeft {
            if randomSource.nextUniform() >= spawnChance, let bubble = addBubble() {
                bubblesView.addSubview(bubble)
                bubble.appear()
            }
        }
    }

    func addBubble() -> BubbleView? {
        let model = BubbleModel.random(roll: randomSource.nextInt(upperBound: 100))
        let maxX = max(bubblesView.bounds.width - CGFloat(BubbleView.size), 0)
        let maxY = max(bubblesView.bounds.height - CGFloat(BubbleView.size), 0)
        let bubble = BubbleView(x: Int(CGFloat(randomSource.nextUniform()) * maxX),
                                y: Int(CGFloat(randomSource.nextUniform()) * maxY),
                                model: model)
        bubble.addTarget(self, action: #selector(popBubble), for: .touchUpInside)
        return checkBubblePosition(bubble: bubble) ? bubble : nil
    }

    func checkBubblePosition(bubble: BubbleView) -> Bool {
        for bubbleView in bubblesView.subviews {
            if let existing = bubbleView as? BubbleView, existing.frame.intersects(bubble.frame) {
                return false
            }
        }
        return true
    }

    @objc func popBubble(button: UIButton) {
        guard !finished, let bubbleView = button as? BubbleView,
              bubbleView.isUserInteractionEnabled else { return }
        bubbleView.pop()
        let point = bubbleView.model.point
        if bubbleView.model.color == lastColor {
            score += Int(Double(point) * comboMultiplier)
        } else {
            score += point
        }
        scoreLabel.text = String(score)
        if score > highScore {
            highScore = score
            highScoreLabel.text = String(highScore)
        }
        lastColor = bubbleView.model.color
    }

}
