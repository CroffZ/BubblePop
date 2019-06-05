//
//  GameViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import UIKit
import GameKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var bubblesView: UIView!
    
    let randomSource: GKRandomSource = GKARC4RandomSource()
    let dataStorage = DataStorage()
    
    var player: String?
    var settings: GameSettings?
    var timer: Timer?
    var timeLeft: Int = 60
    var finish = false
    var last: UIColor?
    var score: Int = 0
    var records: [ScoreRecord] = []
    var highScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Load settings and records
            settings = try dataStorage.loadGameSettings()
            records = try dataStorage.loadScoreRecord()
        } catch {
            // Use default settings and empty records
            settings = GameSettings(gameTime: 60, maxBubbles: 15)
            records = []
        }
        
        // Initialize highest score
        if !records.isEmpty {
            highScore = records[0].score
            highScoreLabel.text = String(highScore)
        }
        
        // Initialize time label
        timeLeft = settings?.gameTime ?? 60
        timeLabel.text = String(timeLeft)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Initialize the timer and start it
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateTimeLabel()
            self.updateBubbles()
        })
        timer?.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Remove all bubbles
        for bubbleView in self.bubblesView.subviews {
            if let bubble = bubbleView as? BubbleView {
                bubble.disappear()
            }
        }
    }
    
    func updateTimeLabel() {
        if self.timeLeft > 0 {
            // Game continues
            self.timeLeft -= 1
            self.timeLabel.text = "\(self.timeLeft)"
        } else {
            // Game over
            timer?.invalidate()
            if !finish {
                // Show alert with information
                let player = self.player ?? "Default"
                let alertController = UIAlertController(title: "Game Over", message: "\(player), your score is \(score)", preferredStyle: .alert)
                self.present(alertController, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        alertController.dismiss(animated: true) {
                            self.performSegue(withIdentifier: "ScoreboardViewSegue", sender: nil)
                        }
                    }
                }
                
                // Save the record
                records.append(ScoreRecord(player: player, score: score))
                records.sort(by: { $0.score > $1.score })
                do {
                    try dataStorage.saveData(scores: records)
                } catch {
                    print(error)
                }
                
                finish = true
            }
        }
    }
    
    func updateBubbles() {
        // Remove some bubbles
        for bubbleView in bubblesView.subviews {
            if randomSource.nextUniform() >= 0.7 {
                if let bubble = bubbleView as? BubbleView {
                    bubble.disappear()
                }
            }
        }
        
        // Add some bubbles
        let spaceLeft = (settings?.maxBubbles ?? 15) - bubblesView.subviews.count
        for _ in 0..<spaceLeft {
            if randomSource.nextUniform() >= 0.5 {
                if let bubble = addBubble() {
                    self.bubblesView.addSubview(bubble)
                    bubble.appear()
                }
            }
        }
    }
    
    func addBubble() -> BubbleView? {
        // Percentage of bubble types
        let model: BubbleModel
        let random = randomSource.nextInt(upperBound: 100)
        if random < 40 {
            model = BubbleModel.red
        } else if random < 70 {
            model = BubbleModel.pink
        } else if random < 85 {
            model = BubbleModel.green
        } else if random < 95 {
            model = BubbleModel.blue
        } else {
            model = BubbleModel.black
        }
        
        // Random position
        let randomX = CGFloat(randomSource.nextUniform()) * (self.bubblesView.frame.width - CGFloat(BubbleView.SIZE))
        let randomY = CGFloat(randomSource.nextUniform()) * (self.bubblesView.frame.height - CGFloat(BubbleView.SIZE))
        let bubble = BubbleView(x: Int(randomX), y: Int(randomY), model: model)
        bubble.addTarget(self, action: #selector(popBubble), for: .touchUpInside)
        
        // Check bubble overlaps
        if checkBubblePosition(bubble: bubble) {
            return bubble
        } else {
            return nil
        }
    }
    
    func checkBubblePosition(bubble: BubbleView) -> Bool {
        for bubbleView in self.bubblesView.subviews {
            if let exist = bubbleView as? BubbleView {
                if exist.frame.intersects(bubble.frame) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func popBubble(button: UIButton) {
        if let bubbleView = button as? BubbleView {
            bubbleView.pop()
            let point = bubbleView.model.point
            if bubbleView.model.color == last {
                self.score += Int(Double(point) * 1.5)
            } else {
                self.score += point
            }
            self.scoreLabel.text = String(self.score)
            if score > highScore {
                highScore = score
                self.highScoreLabel.text = String(self.highScore)
            }
            last = bubbleView.model.color
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
