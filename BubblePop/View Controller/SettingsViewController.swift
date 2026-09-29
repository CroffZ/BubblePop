//
//  SettingsViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. Licensed under the MIT License.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var maxBubblesLabel: UILabel!
    @IBOutlet weak var maxBubblesSlider: UISlider!
    @IBOutlet weak var gameTimeSlider: UISlider!

    private let dataStorage = DataStorage()

    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = (try? dataStorage.loadGameSettings()) ?? GameSettings()
        gameTimeSlider.minimumValue = Float(GameSettings.gameTimeRange.lowerBound)
        gameTimeSlider.maximumValue = Float(GameSettings.gameTimeRange.upperBound)
        maxBubblesSlider.minimumValue = Float(GameSettings.maxBubblesRange.lowerBound)
        maxBubblesSlider.maximumValue = Float(GameSettings.maxBubblesRange.upperBound)
        gameTimeSlider.value = Float(settings.gameTime)
        maxBubblesSlider.value = Float(settings.maxBubbles)
        gameTimeSliderValueChanged(gameTimeSlider)
        maxBubblesSliderValueChanged(maxBubblesSlider)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }

    @IBAction func pressBack(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func gameTimeSliderValueChanged(_ sender: UISlider) {
        gameTimeLabel.text = "\(Int(sender.value))"
    }

    @IBAction func maxBubblesSliderValueChanged(_ sender: UISlider) {
        maxBubblesLabel.text = "\(Int(sender.value))"
    }

    private func saveSettings() {
        let settings = GameSettings(gameTime: Int(gameTimeSlider.value), maxBubbles: Int(maxBubblesSlider.value))
        do {
            try dataStorage.saveData(settings: settings)
        } catch {
            print(error)
        }
    }
}