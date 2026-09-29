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
    
    let dataStorage = DataStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Load previous settings
            let gameSettings = try dataStorage.loadGameSettings()
            gameTimeSlider.value = Float(gameSettings.gameTime)
            maxBubblesSlider.value = Float(gameSettings.maxBubbles)
        } catch {
            // Use the default values
            let gameSettings = GameSettings(gameTime: 60, maxBubbles: 15)
            gameTimeSlider.value = Float(gameSettings.gameTime)
            maxBubblesSlider.value = Float(gameSettings.maxBubbles)
        }
        
        // Manually update the slider values
        self.gameTimeSliderValueChanged(self.gameTimeSlider)
        self.maxBubblesSliderValueChanged(self.maxBubblesSlider)
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