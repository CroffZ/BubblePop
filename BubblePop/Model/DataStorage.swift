//
//  DataStorage.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import Foundation

struct DataStorage: Codable {
    
    let gameSettingsArchiveURL: URL
    let scoreBoardArchiveURL: URL
    
    // Definition of data errors
    enum DataError: Error {
        case dataNotFound
        case dataNotSaved
    }
    
    init() {
        // Set up URLs
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        gameSettingsArchiveURL = documentsDirectory.appendingPathComponent("GameSettings").appendingPathExtension("json")
        scoreBoardArchiveURL = documentsDirectory.appendingPathComponent("ScoreBoard").appendingPathExtension("json")
    }
    
    func read(from archive: URL) throws -> Data {
        if let data = try? Data(contentsOf: archive) {
            return data
        }
        throw DataError.dataNotFound
    }
    
    func write(_ data: Data, to archive: URL) throws {
        do {
            try data.write(to: archive, options: .noFileProtection)
        }
        catch {
            throw DataError.dataNotSaved
        }
    }
    
    func saveData(settings: GameSettings) throws {
        let data = try JSONEncoder().encode(settings)
        try write(data, to: gameSettingsArchiveURL)
    }
    
    func saveData(scores: [ScoreRecord]) throws {
        let data = try JSONEncoder().encode(scores)
        try write(data, to: scoreBoardArchiveURL)
    }
    
    func loadGameSettings() throws -> GameSettings {
        let data = try read(from: gameSettingsArchiveURL)
        if let result = try? JSONDecoder().decode(GameSettings.self, from: data) {
            return result
        }
        throw DataError.dataNotFound
    }
    
    func loadScoreRecord() throws -> [ScoreRecord] {
        let data = try read(from: scoreBoardArchiveURL)
        if let result = try? JSONDecoder().decode([ScoreRecord].self, from: data) {
            return result
        }
        throw DataError.dataNotFound
    }
    
}
