//
//  MainViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let time = 60
    let maxBubble = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startNewGame(_ sender: Any) {
        // Use an alert to get player name from user
        var inputText: UITextField = UITextField();
        let alertController = UIAlertController.init(title: "Input your name:", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default) { (action: UIAlertAction) -> () in
            self.performSegue(withIdentifier: "GameViewSegue", sender: inputText.text)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { (textField) in
            inputText = textField
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GameViewSegue" {
            if let destination = segue.destination as? GameViewController {
                destination.player = sender as? String
            }
        }
    }
    
}
