//
//  NetworkManagerTests.swift
//  MealsInformationTests
//
//  Created by Jay Lliguichushca on 8/29/24.
//

@testable import MealsInformation
import SwiftUI
import XCTest

/// Mock URL Session
class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}

/// Mock Cache Manager
actor MockCacheManager: CacheManagerProtocol {
    var cachedData: [String: Data] = [:]
    var cachedImages: [URL: Image] = [:]

    func setImage(_ image: Image, forURL url: URL) {
        cachedImages[url] = image
    }

    func getImage(forURL url: URL) -> Image? {
        return cachedImages[url]
    }

    func setData(_ data: Data, forKey key: String) {
        cachedData[key] = data
    }

    func getData(forKey key: String) -> Data? {
        return cachedData[key]
    }
}

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    var mockCacheManager: MockCacheManager!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        mockCacheManager = MockCacheManager()
        networkManager = NetworkManager(urlSession: mockURLSession, cacheManager: mockCacheManager)
    }

    override func tearDown() {
        networkManager = nil
        mockURLSession = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
    /// Tests successful completion of API call
    func testFetchMealsSuccess() async throws {
        let jsonString = """
        {
            "meals": [
                {
                    "strMeal": "Choc Chip Pecan Pie",
                    "strMealThumb": "https://www.themealdb.com/images/media/meals/rqvwxt1511384809.jpg",
                    "idMeal": "52856"
                },
                {
                    "strMeal": "Chocolate Avocado Mousse",
                    "strMealThumb": "https://www.themealdb.com/images/media/meals/uttuxy1511382180.jpg",
                    "idMeal": "52853"
                }
            ]
        }
        """
        let jsonData = Data(jsonString.utf8)
        mockURLSession.data = jsonData
        mockURLSession.response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let meals = try await networkManager.fetchMeals()

        XCTAssertEqual(meals.count, 2)
        XCTAssertEqual(meals[0].id, "52856")
        XCTAssertEqual(meals[0].name, "Choc Chip Pecan Pie")
        XCTAssertEqual(meals[0].thumbnailURL, "https://www.themealdb.com/images/media/meals/rqvwxt1511384809.jpg")
        XCTAssertEqual(meals[1].id, "52853")
        XCTAssertEqual(meals[1].name, "Chocolate Avocado Mousse")
        XCTAssertEqual(meals[1].thumbnailURL, "https://www.themealdb.com/images/media/meals/uttuxy1511382180.jpg")
    }
    
    /// Tests getting meals from cache
    func testFetchMealsFromCache() async throws {
        // Given
        let jsonString = """
        {
            "meals": [
                    {
                        "strMeal": "Chocolate Caramel Crispy",
                        "strMealThumb": "https://www.themealdb.com/images/media/meals/1550442508.jpg",
                        "idMeal": "52966"
                    }
            ]
        }
        """
        let jsonData = Data(jsonString.utf8)
        await mockCacheManager.setData(jsonData, forKey: "MealsList")
        let meals = try await networkManager.fetchMeals()

        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals[0].id, "52966")
        XCTAssertEqual(meals[0].name, "Chocolate Caramel Crispy")
        XCTAssertEqual(meals[0].thumbnailURL, "https://www.themealdb.com/images/media/meals/1550442508.jpg")
    }
    
    /// Tests network errors for API call
    func testFetchMealsNetworkError() async {
        mockURLSession.error = NSError(domain: "NetworkError", code: 0, userInfo: nil)

        do {
            _ = try await networkManager.fetchMeals()
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
