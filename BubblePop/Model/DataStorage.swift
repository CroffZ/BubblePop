//
//  DataStorage.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import Foundation

struct DataStorage {

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

    func saveData(settings: GameSettings) throws {
        try save(settings, to: gameSettingsArchiveURL)
    }

    func saveData(scores: [ScoreRecord]) throws {
        try save(scores, to: scoreBoardArchiveURL)
    }

    func loadGameSettings() throws -> GameSettings {
        return try load(from: gameSettingsArchiveURL)
    }

    func loadScoreRecord() throws -> [ScoreRecord] {
        return try load(from: scoreBoardArchiveURL)
    }

    private func load<Value: Decodable>(from archive: URL) throws -> Value {
        let data = try Data(contentsOf: archive)
        return try JSONDecoder().decode(Value.self, from: data)
    }

    private func save<Value: Encodable>(_ value: Value, to archive: URL) throws {
        let data = try JSONEncoder().encode(value)
        // Replace the file only after the complete JSON has been written.
        try data.write(to: archive, options: .atomic)
    }
}