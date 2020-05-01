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

    var setup: Setup {
        didSet {
            loadLocal()
        }
    }
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

    func loadLocal() {
        localPlayerScoreValue = loadInt(forKey: .localPlayerScore) ?? 0
        bestScoreValue = loadInt(forKey: .bestScore) ?? 0
    }

    private func save(_ value: Int, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: "\(leaderboardIdentifier)_\(key.rawValue)")
    }

    private func loadInt(forKey key: UserDefaultsKey) -> Int? {
        UserDefaults.standard.object(forKey: "\(leaderboardIdentifier)_\(key.rawValue)") as? Int
    }

    func report(score: Int) {
        if score > localPlayerScoreValue {
            localPlayerScoreValue = score
            save(localPlayerScoreValue, forKey: .localPlayerScore)
        }
        if score > bestScoreValue {
            bestScoreValue = score
            save(bestScoreValue, forKey: .bestScore)
        }
        let newScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
        newScore.value = Int64(score)
        GKScore.report([newScore])
    }

    func upateLocalPlayerScore() {
        let leaderBoard = GKLeaderboard()
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 1)
        leaderBoard.identifier = leaderboardIdentifier
        leaderBoard.loadScores { [unowned self] (scores: [GKScore]?, error: Error?) -> Void in
            if let error = error {
                print(error)
            } else {
                guard let scores = scores else { return }
                if let score = leaderBoard.localPlayerScore?.value {
                    if Int(score) > self.localPlayerScoreValue {
                        self.localPlayerScoreValue = Int(score)
                        self.save(self.localPlayerScoreValue, forKey: .localPlayerScore)
                    } else if Int(score) < self.localPlayerScoreValue {
                        self.report(score: self.localPlayerScoreValue)
                    }
                }
                if scores.count > 0 {
                    if Int(scores[0].value) > self.bestScoreValue {
                        self.bestScoreValue = Int(scores[0].value)
                        self.save(self.bestScoreValue, forKey: .bestScore)
                    }
                }
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
                        if Int(scores[0].value) > self.bestScoreValue {
                            self.bestScoreValue = Int(scores[0].value)
                            self.save(self.bestScoreValue, forKey: .bestScore)
                        }
                        if let playerScore = leaderBoard.localPlayerScore {
                            localPlayerScore = playerScore
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
        top.map {
            var isHighlighted = false
            var score = Int($0.value)
            if $0.player.playerID == localPlayerID {
                isHighlighted = true
                score = max(score, localPlayerScoreValue)
            }
            return ScoreRow(player: $0.player.displayName,
                            rank: "\($0.rank)",
                value: "\(score)",
                isHighlighted: isHighlighted)
        }
    }

    func createMart(top: [GKScore], peers: [GKScore], localPlayerID: String) -> [ScoreRow] {
        var result = top[0..<3].map { ScoreRow($0, isHighlighted: false) }
        result.append(ScoreRow(player: "...", rank: "...", value: "...", isHighlighted: false))
        result.append(contentsOf: peers.map {
            var isHighlighted = false
            var score = Int($0.value)
            if $0.player.playerID == localPlayerID {
                isHighlighted = true
                score = max(score, localPlayerScoreValue)
            }
            return ScoreRow(player: $0.player.displayName,
                            rank: "\($0.rank)",
                value: "\(score)",
                isHighlighted: isHighlighted)
        })
        return result
    }
}
