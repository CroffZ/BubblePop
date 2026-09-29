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
    private let removalThreshold: Float = 0.7
    private let spawnThreshold: Float = 0.5

    var player: String?
    private var settings = GameSettings()
    private var timer: Timer?
    private var timeLeft = GameSettings().gameTime
    private var finished = false
    private var isVisible = false
    private var score = GameScore()
    private var records: [ScoreRecord] = []

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
        score = GameScore(highScore: records.map { $0.score }.max() ?? 0)
        updateScoreLabels()

        timeLeft = settings.gameTime
        timeLabel.text = String(timeLeft)

        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        startTimerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
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
        startTimerIfNeeded()
    }

    private func startTimerIfNeeded() {
        guard timer == nil, !finished, isVisible,
              UIApplication.shared.applicationState == .active else { return }
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
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
        records.append(ScoreRecord(player: player, score: score.total))
        var message = "\(player), your score is \(score.total)"
        do {
            try dataStorage.saveData(scores: records)
        } catch {
            message += "\nYour score could not be saved."
        }

        let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "See Scores", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "ScoreboardViewSegue", sender: nil)
        })
        present(alertController, animated: true)
    }

    func updateBubbles() {
        for bubbleView in bubblesView.subviews {
            if randomSource.nextUniform() >= removalThreshold, let bubble = bubbleView as? BubbleView {
                bubble.disappear()
            }
        }

        let spaceLeft = settings.maxBubbles - bubblesView.subviews.count
        guard spaceLeft > 0 else { return }
        for _ in 0..<spaceLeft {
            if randomSource.nextUniform() >= spawnThreshold, let bubble = addBubble() {
                bubblesView.addSubview(bubble)
                bubble.appear()
            }
        }
    }

    func addBubble() -> BubbleView? {
        let model = BubbleModel.random(roll: randomSource.nextInt(upperBound: BubbleModel.totalWeight))
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
        score.record(bubbleView.model)
        updateScoreLabels()
    }

    private func updateScoreLabels() {
        scoreLabel.text = String(score.total)
        highScoreLabel.text = String(score.highScore)
    }
}
