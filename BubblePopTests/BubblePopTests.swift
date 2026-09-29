import XCTest
import UIKit
@testable import BubblePop

final class GameSettingsTests: XCTestCase {
    func testSettingsClampToExistingSliderRanges() {
        XCTAssertEqual(GameSettings(gameTime: -1, maxBubbles: 0),
                       GameSettings(gameTime: 15, maxBubbles: 5))
        XCTAssertEqual(GameSettings(gameTime: 999, maxBubbles: 999),
                       GameSettings(gameTime: 120, maxBubbles: 20))
    }

    func testSettingsKeepValidValues() {
        let settings = GameSettings(gameTime: 45, maxBubbles: 12)
        XCTAssertEqual(settings.gameTime, 45)
        XCTAssertEqual(settings.maxBubbles, 12)
    }

    func testDecodedSettingsAreValidated() throws {
        let data = Data(#"{"gameTime":-10,"maxBubbles":200}"#.utf8)
        let settings = try JSONDecoder().decode(GameSettings.self, from: data)
        XCTAssertEqual(settings, GameSettings(gameTime: 15, maxBubbles: 20))
    }

    func testSettingsEncodingPreservesSavedFileFormat() throws {
        let data = try JSONEncoder().encode(GameSettings())
        let values = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Int])
        XCTAssertEqual(values, ["gameTime": 60, "maxBubbles": 15])
    }
}

final class DataStorageTests: XCTestCase {
    private var directory: URL!
    private var storage: DataStorage!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        storage = DataStorage(directory: directory)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: directory)
        storage = nil
        directory = nil
    }

    func testDefaultSettings() {
        let settings = GameSettings()
        XCTAssertEqual(settings.gameTime, 60)
        XCTAssertEqual(settings.maxBubbles, 15)
    }

    func testSettingsRoundTrip() throws {
        try storage.saveData(settings: GameSettings(gameTime: 90, maxBubbles: 20))
        let restored = try storage.loadGameSettings()
        XCTAssertEqual(restored.gameTime, 90)
        XCTAssertEqual(restored.maxBubbles, 20)
    }

    func testScoresRoundTripPreservesNamesAndOrder() throws {
        let scores = [ScoreRecord(player: "Zoë 🫧", score: 42), ScoreRecord(player: "Player", score: 0)]
        try storage.saveData(scores: scores)
        let restored = try storage.loadScoreRecord()
        XCTAssertEqual(restored.map { $0.player }, scores.map { $0.player })
        XCTAssertEqual(restored.map { $0.score }, scores.map { $0.score })
    }

    func testClearingScoresPersistsEmptyArray() throws {
        try storage.saveData(scores: [ScoreRecord(player: "Player", score: 10)])
        try storage.saveData(scores: [])
        XCTAssertTrue(try storage.loadScoreRecord().isEmpty)
    }

    func testSavingSettingsReplacesPreviousFile() throws {
        try storage.saveData(settings: GameSettings(gameTime: 120, maxBubbles: 20))
        try storage.saveData(settings: GameSettings(gameTime: 15, maxBubbles: 5))
        let restored = try storage.loadGameSettings()
        XCTAssertEqual(restored.gameTime, 15)
        XCTAssertEqual(restored.maxBubbles, 5)
    }

    func testMissingFilesThrow() {
        XCTAssertThrowsError(try storage.loadGameSettings())
        XCTAssertThrowsError(try storage.loadScoreRecord())
    }

    func testMalformedSettingsPreservesDecodingError() throws {
        try Data("not JSON".utf8).write(to: storage.gameSettingsArchiveURL)
        XCTAssertThrowsError(try storage.loadGameSettings()) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testMalformedScoresPreservesDecodingError() throws {
        try Data("{}".utf8).write(to: storage.scoreBoardArchiveURL)
        XCTAssertThrowsError(try storage.loadScoreRecord()) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testScoresLoadIndependentlyOfSettings() throws {
        try storage.saveData(scores: [ScoreRecord(player: "Player", score: 8)])
        XCTAssertThrowsError(try storage.loadGameSettings())
        XCTAssertEqual(try storage.loadScoreRecord().first?.score, 8)
    }

    func testWriteFailureThrows() {
        let missingDirectory = directory.appendingPathComponent("missing", isDirectory: true)
        let invalidStorage = DataStorage(directory: missingDirectory)
        XCTAssertThrowsError(try invalidStorage.saveData(settings: GameSettings()))
    }
}

@MainActor
final class GameplayTests: XCTestCase {
    func testScoreModelAppliesComboAndResetsForDifferentColor() {
        var score = GameScore()
        score.record(.green)
        XCTAssertEqual(score.total, 5)
        score.record(.green)
        XCTAssertEqual(score.total, 12)
        score.record(.blue)
        XCTAssertEqual(score.total, 20)
        score.record(.blue)
        XCTAssertEqual(score.total, 32)
        XCTAssertEqual(score.highScore, 32)
    }

    func testScoreModelKeepsSavedHighScoreUntilExceeded() {
        var score = GameScore(highScore: 20)
        XCTAssertEqual(score.total, 0)
        score.record(.black)
        XCTAssertEqual(score.highScore, 20)
        score.record(.black)
        XCTAssertEqual(score.total, 25)
        XCTAssertEqual(score.highScore, 25)
    }

    func testScoreModelRoundsDownOnePointCombo() {
        var score = GameScore()
        score.record(.red)
        score.record(.red)
        XCTAssertEqual(score.total, 2)
    }

    func testEverySpawnRollMatchesDocumentedWeights() {
        let counts = Dictionary(grouping: (0..<100).map { BubbleModel.random(roll: $0).name }, by: { $0 })
            .mapValues { $0.count }
        XCTAssertEqual(counts, ["Red": 40, "Pink": 30, "Green": 15, "Blue": 10, "Black": 5])
        XCTAssertEqual(BubbleModel.all.map { $0.point }, [1, 2, 5, 8, 10])
    }

    func testSameColorComboRoundsDownAndDifferentColorResetsIt() {
        let controller = GameViewController()
        let scoreLabel = UILabel()
        let highScoreLabel = UILabel()
        controller.scoreLabel = scoreLabel
        controller.highScoreLabel = highScoreLabel

        controller.popBubble(button: BubbleView(x: 0, y: 0, model: .green))
        XCTAssertEqual(scoreLabel.text, "5")
        controller.popBubble(button: BubbleView(x: 0, y: 0, model: .green))
        XCTAssertEqual(scoreLabel.text, "12")
        controller.popBubble(button: BubbleView(x: 0, y: 0, model: .blue))
        XCTAssertEqual(scoreLabel.text, "20")
        XCTAssertEqual(highScoreLabel.text, "20")
    }

    func testOnePointComboRoundsDown() {
        let controller = GameViewController()
        let scoreLabel = UILabel()
        let highScoreLabel = UILabel()
        controller.scoreLabel = scoreLabel
        controller.highScoreLabel = highScoreLabel
        controller.popBubble(button: BubbleView(x: 0, y: 0, model: .red))
        controller.popBubble(button: BubbleView(x: 0, y: 0, model: .red))
        XCTAssertEqual(scoreLabel.text, "2")
    }

    func testRepeatedTapOnlyScoresOnce() {
        let controller = GameViewController()
        let scoreLabel = UILabel()
        let highScoreLabel = UILabel()
        controller.scoreLabel = scoreLabel
        controller.highScoreLabel = highScoreLabel
        let bubble = BubbleView(x: 0, y: 0, model: .black)
        controller.popBubble(button: bubble)
        controller.popBubble(button: bubble)
        XCTAssertEqual(scoreLabel.text, "10")
        XCTAssertFalse(bubble.isUserInteractionEnabled)
    }

    func testDisappearingBubbleCannotScore() {
        let controller = GameViewController()
        let scoreLabel = UILabel()
        controller.scoreLabel = scoreLabel
        scoreLabel.text = "0"
        let bubble = BubbleView(x: 0, y: 0, model: .black)
        bubble.disappear()
        controller.popBubble(button: bubble)
        XCTAssertEqual(scoreLabel.text, "0")
        XCTAssertFalse(bubble.isUserInteractionEnabled)
    }

    func testOverlappingBubblesAreRejected() {
        let controller = GameViewController()
        let playArea = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        controller.bubblesView = playArea
        playArea.addSubview(BubbleView(x: 0, y: 0, model: .red))
        XCTAssertFalse(controller.checkBubblePosition(bubble: BubbleView(x: 40, y: 40, model: .blue)))
        XCTAssertTrue(controller.checkBubblePosition(bubble: BubbleView(x: 100, y: 100, model: .blue)))
    }

    func testBubbleAccessibilityDescribesColorAndPoints() {
        let bubble = BubbleView(x: 0, y: 0, model: .blue)
        XCTAssertTrue(bubble.isAccessibilityElement)
        XCTAssertEqual(bubble.accessibilityLabel, "Blue bubble, 8 points")
    }
}