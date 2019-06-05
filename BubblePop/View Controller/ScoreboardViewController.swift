//
//  ScoreboardViewController.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import UIKit

class ScoreboardViewController: UITableViewController {
    
    let dataStorage = DataStorage()
    
    var records: [ScoreRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load records
        do {
            records = try dataStorage.loadScoreRecord()
        } catch {
            records = []
        }
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Button Functions
    
    @IBAction func pressBack(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreRecordTableViewCell", for: indexPath) as! ScoreRecordTableViewCell
        let record = records[indexPath.row]
        cell.playerLabel.text = record.player
        cell.scoreLabel.text = "\(record.score)"
        return cell
    }
    
}
