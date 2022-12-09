import Foundation

protocol StatisticService: AnyObject {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Float { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case bestGame, bestResult
    }

    func store(correct count: Int, total amount: Int) {
        let possibleBestGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < possibleBestGame {
            bestGame = possibleBestGame
        }
        bestResultsArray.append(count)
    }

    var totalAccuracy: Float {
        let sumOfAllResults = bestResultsArray.reduce(0, +)
        let accuracy = Float(sumOfAllResults * 100) / Float((bestGame.total) * bestResultsArray.count)
        return accuracy
    }

    var gamesCount: Int {
        return bestResultsArray.count
    }

    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    private(set) var bestResultsArray: [Int] {
        get {
            return userDefaults.object(forKey: Keys.bestResult.rawValue) as? [Int] ?? [Int]()
        }
        set {
            userDefaults.set(newValue, forKey: Keys.bestResult.rawValue)
        }
    }
}
