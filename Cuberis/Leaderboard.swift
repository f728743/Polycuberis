//
//  Leaderboard.swift
//  Cuberis
//

import UIKit
import GameKit

struct ScoreRow {
    let player: String
    let rank: String
    let value: String
    let isHighlighted: Bool
}

extension ScoreRow {
    init(_ score: GKScore, isHighlighted: Bool) {
        self.init(player: score.player.displayName,
                  rank: "\(score.rank)",
            value: "\(score.value)",
            isHighlighted: isHighlighted)
    }
}

class Leaderboard: NSObject {
    enum UserDefaultsKey: String {
        case localPlayerScore
        case bestScore
    }

    var setup: Setup
    private(set) var localPlayerScoreValue = 0
    private(set) var bestScoreValue = 0

    func authenticateUser(rootViewController: UIViewController) {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { [unowned self] vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            if let vc = vc {
                rootViewController.present(vc, animated: true, completion: nil)
            }
            self.upateLocalPlayerScore()
        }
    }

    var leaderboardIdentifier: String {
        let name = "Polycuberis\(GameMode.names[setup.mode.rawValue].replacingOccurrences(of: " ", with: ""))"
        let w = setup.pitSize.width
        let h = setup.pitSize.height
        let set = PolycubeSet.names[setup.polycubeSet.rawValue]
        return setup.mode == .custom ? "\(name)\(min(w, h))x\(max(w, h))\(set)" : name
    }

    init(setup: Setup) {
        self.setup = setup
        super.init()
        loadLocal()
    }

    func saveLocal() {
        save(localPlayerScoreValue, forKey: .localPlayerScore)
        save(bestScoreValue, forKey: .bestScore)
    }

    func loadLocal() {
        localPlayerScoreValue = loadInt(forKey: .localPlayerScore) ?? 0
        bestScoreValue = loadInt(forKey: .bestScore) ?? 0
    }

    private func save(_ value: Int, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: "\(leaderboardIdentifier).\(key.rawValue)")
    }

    private func loadInt(forKey key: UserDefaultsKey) -> Int? {
        return UserDefaults.standard.object(forKey: "\(leaderboardIdentifier).\(key.rawValue)") as? Int
    }

    func report(score: Int) {
        if score > localPlayerScoreValue {
            localPlayerScoreValue = score
        }
        if score > bestScoreValue {
            bestScoreValue = score
        }
        saveLocal()
        let newScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
        newScore.value = Int64(score)
        GKScore.report([newScore]) { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }

    func upateLocalPlayerScore() {
        localPlayerScoreValue = 0
        bestScoreValue = 0
        let leaderBoard = GKLeaderboard()
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 1)
        leaderBoard.identifier = leaderboardIdentifier
        leaderBoard.loadScores { [unowned self] (score: [GKScore]?, error: Error?) -> Void in
            if let error = error {
                print(error)
            } else {
                guard let score = score else { return }
                if let score = leaderBoard.localPlayerScore?.value {
                    self.localPlayerScoreValue = Int(score)
                }
                if score.count > 0 {
                    self.bestScoreValue = Int(score[0].value)
                }
                self.saveLocal()
            }
        }
    }

    func loadHighScores(completion: @escaping (([ScoreRow]) -> Void)) {
        let leaderBoard = GKLeaderboard()
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 7)
        leaderBoard.identifier = leaderboardIdentifier

        var top = [GKScore]()
        leaderBoard.loadScores { [unowned self] (scores: [GKScore]?, error: Error?) -> Void in
            var localPlayerScore: GKScore?
            if let error = error {
                print(error)
            } else {
                if let scores = scores {
                    if scores.count > 0 {
                        top = scores
                        self.bestScoreValue = Int(scores[0].value)
                        self.saveLocal()
                        if let playerScore = leaderBoard.localPlayerScore {
                            localPlayerScore = playerScore
                            self.localPlayerScoreValue = Int(playerScore.value)
                            self.saveLocal()
                            if playerScore.rank < 8 {
                                completion(self.createMart(top: top, localPlayerID: playerScore.player.playerID))
                                return
                            }
                        } else {
                            completion(self.createMart(top: top, localPlayerID: nil))
                            return
                        }
                    }
                }
            }
            if let localPlayerScore = localPlayerScore {
                leaderBoard.range = NSRange(location: localPlayerScore.rank - 1, length: 3)
                leaderBoard.loadScores { [unowned self] (scores: [GKScore]?, error: Error?) -> Void in
                    if let error = error {
                        print(error)
                        completion(self.createOfflineMart())
                    } else {
                        if let scores = scores {
                            if scores.count > 0 {
                                completion(self.createMart(top: top,
                                                           peers: scores,
                                                           localPlayerID: localPlayerScore.player.playerID))
                                return
                            }
                        }
                    }
                    completion(self.createMart(localPlayer: localPlayerScore))
                    return
                }
            }
            completion(self.createOfflineMart())
            return
        }
    }

    func createOfflineMart() -> [ScoreRow] {
        [ScoreRow(player: "You", rank: "?", value: "\(localPlayerScoreValue)", isHighlighted: true)]
    }

    func createMart(localPlayer: GKScore) -> [ScoreRow] {
        [ScoreRow(localPlayer, isHighlighted: true)]
    }

    func createMart(top: [GKScore], localPlayerID: String?) -> [ScoreRow] {
        top.map { ScoreRow($0, isHighlighted: $0.player.playerID == localPlayerID) }
    }

    func createMart(top: [GKScore], peers: [GKScore], localPlayerID: String) -> [ScoreRow] {
        var result = top[0..<3].map { ScoreRow($0, isHighlighted: false) }
        result.append(ScoreRow(player: "...", rank: "...", value: "...", isHighlighted: false))
        result.append(contentsOf: peers.map { ScoreRow($0, isHighlighted: $0.player.playerID == localPlayerID) })
        return result
    }
/*
    func createMart() -> [ScoreRow] {
        return [
            ScoreRow(player: "习近平", rank: "1", value: "2412043", isHighlighted: false),
            ScoreRow(player: "Sun Hui Vchay", rank: "2", value: "2301213", isHighlighted: false),
            ScoreRow(player: "문재인", rank: "3", value: "1967390", isHighlighted: false),
            ScoreRow(player: "...", rank: "...", value: "...", isHighlighted: false),
            ScoreRow(player: "Suka zadrot", rank: "2046", value: "56722", isHighlighted: false),
            ScoreRow(player: "You", rank: "2047", value: "48316", isHighlighted: true),
            ScoreRow(player: "Average Joe", rank: "2048", value: "32555", isHighlighted: false)
        ]
    }
 */

    func test() {
        let mart = createOfflineMart()
        print(mart)
    }
}

extension Leaderboard: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
