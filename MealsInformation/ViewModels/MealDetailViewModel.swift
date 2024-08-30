//
//  MealDetailViewModel.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import Foundation

@MainActor
class MealDetailViewModel: ObservableObject {
    @Published private(set) var mealDetail: MealDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    
    /// Receive mealId from previous view
    private let mealId: String
    
    private let networkManager: NetworkManagerProtocol
    
    init(mealId: String, networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.mealId = mealId
        self.networkManager = networkManager
    }
    
    /// Async function to fetch meal details
    func fetchMealDetail() async {
        isLoading = true
        error = nil
        
        do {
            mealDetail = try await networkManager.fetchMealDetails(id: mealId)
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
}
