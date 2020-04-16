//
//  Leaderboard.swift
//  Cuberis
//

import Foundation

struct ScoreMart {
    let player: String
    let rank: String
    let value: String
    let isHighlighted: Bool
}

class Leaderboard {
    func mart(modeIdentifier: String) -> [ScoreMart] {
        print("modeIdentifier: \(modeIdentifier)")
        return [
            ScoreMart(player: "习近平", rank: "1", value: "2412043", isHighlighted: false),
            ScoreMart(player: "Sun Hui Vchay", rank: "2", value: "2301213", isHighlighted: false),
            ScoreMart(player: "문재인", rank: "3", value: "1967390", isHighlighted: false),
            ScoreMart(player: "...", rank: "...", value: "...", isHighlighted: false),
            ScoreMart(player: "Suka zadrot", rank: "2046", value: "56722", isHighlighted: false),
            ScoreMart(player: "You", rank: "2047", value: "48316", isHighlighted: true),
            ScoreMart(player: "Average Joe", rank: "2048", value: "32555", isHighlighted: false)
        ]
    }

}
