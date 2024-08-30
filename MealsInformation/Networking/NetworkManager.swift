//
//  NetworkManager.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import Foundation
import SwiftUI

/// This protocol allows for dependency injection and testing network calls
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// This protocol allows for dependency injection
protocol CacheManagerProtocol: Actor {
    func setImage(_ image: Image, forURL url: URL)
    func getImage(forURL url: URL) -> Image?
    func setData(_ data: Data, forKey key: String)
    func getData(forKey key: String) -> Data?
}

/// This protocol allows for dependency injection
protocol NetworkManagerProtocol {
    func fetchMeals() async throws -> [Meal]
    func fetchMealDetails(id: String) async throws -> MealDetail
    func fetchImage(from urlString: String) async throws -> Image
}

/// Manages network requests for fetching meal data and images
class NetworkManager: NetworkManagerProtocol {
    private let urlSession: URLSessionProtocol
    private let cacheManager: CacheManagerProtocol
    private let cacheKey = "MealsList"
    
    init(urlSession: URLSessionProtocol = URLSession.shared, cacheManager: CacheManagerProtocol = CacheManager.shared) {
        self.urlSession = urlSession
        self.cacheManager = cacheManager
    }
    
    /// Fetches a list of meals, using cache if available
    func fetchMeals() async throws -> [Meal] {
        if let cachedData = await cacheManager.getData(forKey: cacheKey) {
            do {
                let mealResponse = try JSONDecoder().decode(MealResponse.self, from: cachedData)
                return mealResponse.meals.sorted { $0.name < $1.name }
            } catch {
                throw NetworkError.parsing(error as? DecodingError)
            }
        }
        
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            throw NetworkError.badURL
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }
            
            await cacheManager.setData(data, forKey: cacheKey)
            
            let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
            return mealResponse.meals.sorted { $0.name < $1.name }
        } catch let urlError as URLError {
            throw NetworkError.url(urlError)
        } catch let decodingError as DecodingError {
            throw NetworkError.parsing(decodingError)
        } catch {
            throw NetworkError.unknown
        }
    }
    
    /// Fetches details for a specific meal, using cache if available
    func fetchMealDetails(id: String) async throws -> MealDetail {
        let cacheKey = "MealDetail_\(id)"
        
        if let cachedData = await cacheManager.getData(forKey: cacheKey) {
            do {
                let mealDetailResponse = try JSONDecoder().decode(MealDetailResponse.self, from: cachedData)
                guard let mealDetail = mealDetailResponse.meals.first else {
                    throw NetworkError.unknown
                }
                return mealDetail
            } catch {
                throw NetworkError.parsing(error as? DecodingError)
            }
        }
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            throw NetworkError.badURL
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }
            
            await cacheManager.setData(data, forKey: cacheKey)
            
            let mealDetailResponse = try JSONDecoder().decode(MealDetailResponse.self, from: data)
            guard let mealDetail = mealDetailResponse.meals.first else {
                throw NetworkError.unknown
            }
            
            return mealDetail
        } catch let urlError as URLError {
            throw NetworkError.url(urlError)
        } catch let decodingError as DecodingError {
            throw NetworkError.parsing(decodingError)
        } catch {
            throw NetworkError.unknown
        }
    }
    
    /// Fetches an image from a URL, using cache if available
    func fetchImage(from urlString: String) async throws -> Image {
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }

        if let cachedImage = await cacheManager.getImage(forURL: url) {
            return cachedImage
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }

            guard let uiImage = UIImage(data: data) else {
                throw NetworkError.unknown
            }

            let image = Image(uiImage: uiImage)
            await cacheManager.setImage(image, forURL: url)

            return image
        } catch let urlError as URLError {
            throw NetworkError.url(urlError)
        } catch {
            throw NetworkError.unknown
        }
    }
}
