//
//  DataStorage.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import Foundation

struct DataStorage: Codable {

    let gameSettingsArchiveURL: URL
    let scoreBoardArchiveURL: URL

    /// Supply a separate directory in tests to avoid touching a player's saved data.
    init(directory: URL? = nil) {
        let documentsDirectory = directory
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        gameSettingsArchiveURL = documentsDirectory.appendingPathComponent("GameSettings").appendingPathExtension("json")
        scoreBoardArchiveURL = documentsDirectory.appendingPathComponent("ScoreBoard").appendingPathExtension("json")
    }

    func read(from archive: URL) throws -> Data {
        return try Data(contentsOf: archive)
    }

    func write(_ data: Data, to archive: URL) throws {
        // Replace the file only after the complete JSON has been written.
        try data.write(to: archive, options: .atomic)
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
        return try JSONDecoder().decode(GameSettings.self, from: data)
    }

    func loadScoreRecord() throws -> [ScoreRecord] {
        let data = try read(from: scoreBoardArchiveURL)
        return try JSONDecoder().decode([ScoreRecord].self, from: data)
    }

}