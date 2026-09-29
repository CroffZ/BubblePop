//
//  ScoreboardViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. Licensed under the MIT License.
//

import UIKit

class ScoreboardViewController: UITableViewController {

    private let dataStorage = DataStorage()

    private var records: [ScoreRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecords()
        tableView.tableFooterView = UIView()
    }

    @IBAction func pressBack(_ sender: Any) {
        view.window?.rootViewController?.dismiss(animated: true)
    }

    @IBAction func pressRestart(_ sender: Any) {
        let alert = UIAlertController(title: "Clear scores?", message: "This removes every saved score on this device.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.clearScores()
        })
        present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreRecordTableViewCell", for: indexPath) as? ScoreRecordTableViewCell else {
            return UITableViewCell()
        }
        let record = records[indexPath.row]
        cell.playerLabel.text = record.player
        cell.scoreLabel.text = "\(record.score)"
        cell.accessibilityLabel = "\(record.player), \(record.score) points"
        return cell
    }

    private func loadRecords() {
        records = (try? dataStorage.loadScoreRecord()) ?? []
        records.sort { $0.score > $1.score }
        tableView.reloadData()
    }

    private func clearScores() {
        do {
            try dataStorage.saveData(scores: [])
            records = []
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: "Unable to Clear Scores",
                                          message: "Your saved scores have not been changed. Please try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

}