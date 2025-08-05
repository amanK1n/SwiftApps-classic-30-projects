//
//  Person.swift
//  10FaceNameApp
//
//  Created by Sayed on 03/08/25.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
