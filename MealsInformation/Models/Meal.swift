//
//  Meal.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/26/24.
//

import Foundation

/// Response from the meal list API
struct MealResponse: Codable {
    let meals: [Meal]
}

struct Meal: Identifiable, Codable {
    let id: String
    let name: String
    let thumbnailURL: String

    // Custom coding keys to map JSON keys to struct properties
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case thumbnailURL = "strMealThumb"
    }
}
