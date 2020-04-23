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

class Leaderboard: NSObject {

    var setup = Setup()
    private(set) var localPlayerScore = 0
    private(set) var bestScore = 0

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

    func report(score: Int) {
        if score > localPlayerScore {
            localPlayerScore = score
        }
        if score > bestScore {
            bestScore = score
        }
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
        localPlayerScore = 0
        bestScore = 0
        let leaderBoard = GKLeaderboard()
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 1)
        leaderBoard.identifier = leaderboardIdentifier
        leaderBoard.loadScores { [unowned self] (score: [GKScore]?, error: Error?) -> Void in
            if let error = error {
                print(error)
            } else {
                guard let score = score else { return }
                if score.count > 0 {
                    self.localPlayerScore = Int(leaderBoard.localPlayerScore!.value)
                    self.bestScore = Int(score[0].value)
                    let localPlayerScore = leaderBoard.localPlayerScore!
                    let rank = localPlayerScore.rank
                    print("rank \(rank), value \(localPlayerScore.value)")
                }
            }
        }
    }

    func loadHighScores(completion: @escaping (([ScoreRow]) -> Void)) {
        let leaderBoard = GKLeaderboard()
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 10)
        leaderBoard.identifier = leaderboardIdentifier

        var top = [GKScore]()
        var peers = [GKScore]()
        var localPlayer: GKScore?
        leaderBoard.loadScores { [unowned self] (scores: [GKScore]?, error: Error?) -> Void in
            var localPlayerRank = 0
            if let error = error {
                print(error)
            } else {
                if let scores = scores {
                    if scores.count > 0 {
                        top = scores
                        self.localPlayerScore = Int(leaderBoard.localPlayerScore!.value)
                        self.bestScore = Int(scores[0].value)
                        localPlayer = leaderBoard.localPlayerScore!
                        let localPlayerScore = leaderBoard.localPlayerScore!
                        localPlayerRank = localPlayerScore.rank
                    }
                }
            }
            leaderBoard.range = NSRange(location: localPlayerRank - 3, length: 7)
            leaderBoard.loadScores { [unowned self] (scores: [GKScore]?, error: Error?) -> Void in
                if let error = error {
                    print(error)
                } else {
                    if let scores = scores {
                        if scores.count > 0 {
                            peers = scores
                            self.localPlayerScore = Int(leaderBoard.localPlayerScore!.value)
                            self.bestScore = Int(scores[0].value)
                            let localPlayerScore = leaderBoard.localPlayerScore!
                            localPlayerRank = localPlayerScore.rank
                            localPlayer = leaderBoard.localPlayerScore!
                        }
                    }
                }
                for score in top {
                    print(score.player.displayName)
                }
                for score in peers {
                    print(score.player.displayName, score.player.playerID)
                }
                completion(self.createMart(top, peers, localPlayer))
            }
        }
    }

    func createMart(_ top: [GKScore], _ peers: [GKScore], _ localPlayer: GKScore?) -> [ScoreRow] {
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
}

extension Leaderboard: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
