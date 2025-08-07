//
//  WhackSlot.swift
//  14Penguin
//
//  Created by Sayed on 07/08/25.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    func configure(at position: CGPoint) {
        self.position = position

        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
    }
}
