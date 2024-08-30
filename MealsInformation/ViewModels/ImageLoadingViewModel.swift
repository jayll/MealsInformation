//
//  ImageLoadingViewModel.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/28/24.
//

import Foundation
import SwiftUI

/// ViewModel for asynchronous image loading
@MainActor
class ImageLoadingViewModel: ObservableObject {
    let url: String?
    private let networkManager: NetworkManagerProtocol
    
    @Published private(set) var image: Image?
    @Published private(set) var error: NetworkError?
    @Published private(set) var isLoading = false
    
    init(url: String?, networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.url = url
        self.networkManager = networkManager
    }
    
    /// Fetches image asynchronously if not already loaded
    func fetch() async {
        guard image == nil, !isLoading, let url = url else {
            error = .badURL
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            image = try await networkManager.fetchImage(from: url)
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
}
