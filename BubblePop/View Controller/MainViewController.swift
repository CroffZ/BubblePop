//
//  MainViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func startNewGame(_ sender: Any) {
        let alertController = UIAlertController(title: "Input your name:", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Player"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let name = alertController.textFields?.first?.text
            self?.performSegue(withIdentifier: "GameViewSegue", sender: name)
        }
        alertController.addAction(ok)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "GameViewSegue",
              let destination = segue.destination as? GameViewController else {
            return
        }
        let trimmed = (sender as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        destination.player = trimmed.isEmpty ? "Player" : trimmed
    }

}