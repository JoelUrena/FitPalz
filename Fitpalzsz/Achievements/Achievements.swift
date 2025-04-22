//
//  Achievements.swift
//  Achievements test
//
//  Created by Brian Arias Cano on 4/22/25.
//

import SwiftData

@Model
class Achievement {

    var name: String
    
    var Achievement_description: String
    
    var percent_completed:Double
    
    var criteria: Double
    
    //
    init(name: String, Achievement_description: String, percent_completed: Double, criteria: Double) {
        self.name = name
        self.Achievement_description = Achievement_description
        self.percent_completed = percent_completed
        self.criteria = criteria
    }
    
}
