//
//  MealDetail.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/26/24.
//

import Foundation

///  Response from the meal detail API
struct MealDetailResponse: Decodable {
    let meals: [MealDetail]
}

struct MealDetail: Identifiable, Decodable {
    let id: String
    let mealName: String
    let drinkAlternate: String?
    let category: String
    let area: String
    let instructions: [String]
    let thumbnailURL: String
    let tags: [String]
    let youtubeURL: String
    let ingredients: Ingredients
    let source: String?
    let imageSource: String?
    let creativeCommonsConfirmed: String?
    let dateModified: String?
    // Custom coding keys to map JSON keys to struct properties
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case mealName = "strMeal"
        case drinkAlternate = "strDrinkAlternate"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case tags = "strTags"
        case thumbnailURL = "strMealThumb"
        case youtubeURL = "strYoutube"
        case source = "strSource"
        case imageSource = "strImageSource"
        case creativeCommonsConfirmed = "strCreativeCommonsConfirmed"
        case dateModified
        case ingredients
    }

    // Custom decoding to handle complex data structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        mealName = try container.decode(String.self, forKey: .mealName)
        drinkAlternate = try container.decodeIfPresent(String.self, forKey: .drinkAlternate)
        category = try container.decode(String.self, forKey: .category)
        area = try container.decode(String.self, forKey: .area)
        let instructionsString = try container.decode(String.self, forKey: .instructions)
        instructions = instructionsString.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        if let tagsString = try container.decodeIfPresent(String.self, forKey: .tags) {
            tags = tagsString.isEmpty ? [] : tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        } else {
            tags = []
        }
        thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        youtubeURL = try container.decode(String.self, forKey: .youtubeURL)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        imageSource = try container.decodeIfPresent(String.self, forKey: .imageSource)
        creativeCommonsConfirmed = try container.decodeIfPresent(String.self, forKey: .creativeCommonsConfirmed)
        dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
        ingredients = try Ingredients(from: decoder)
    }
}

/// Collection of ingredients for a meal
struct Ingredients: Decodable {
    let items: [Ingredient]

    struct Ingredient: Decodable {
        let id: UUID
        let name: String
        let measure: String

        init(name: String, measure: String) {
            id = UUID()
            self.name = name
            self.measure = measure
        }
    }

    // Custom coding keys for ingredient and measure properties
    private enum CodingKeys: String, CodingKey {
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    // Custom decoding to handle ingredients
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var ingredients: [Ingredient] = []

        for i in 1 ... 20 {
            guard let ingredientKey = CodingKeys(rawValue: "strIngredient\(i)"),
                  let measureKey = CodingKeys(rawValue: "strMeasure\(i)")
            else {
                continue
            }

            if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
               let measure = try container.decodeIfPresent(String.self, forKey: measureKey),
               !ingredient.isEmpty, !measure.isEmpty
            {
                ingredients.append(Ingredient(name: ingredient, measure: measure))
            }
        }

        items = ingredients
    }
}
