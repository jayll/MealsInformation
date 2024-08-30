//
//  MailListViewModel.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import Foundation

@MainActor
class MealListViewModel: ObservableObject {
    @Published private(set) var meals: [Meal] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    /// Fetches the list of meals from the network
    func fetchMeals() async {
        isLoading = true
        error = nil
        
        do {
            meals = try await networkManager.fetchMeals()
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
}
