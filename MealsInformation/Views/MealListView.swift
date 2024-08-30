//
//  MealListView.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import Foundation
import SwiftUI

struct MealListView: View {
    @StateObject private var viewModel = MealListViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    }
                } else {
                    /// List of meals with search functionality
                    List {
                        ForEach(viewModel.meals.filter { meal in
                            searchText.isEmpty || meal.name.localizedCaseInsensitiveContains(searchText)
                        }) { meal in
                            NavigationLink(destination: MealDetailView(mealId: meal.id, mealName: meal.name)) {
                                MealRow(meal: meal)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search desserts")
                }
            }
            .navigationTitle("Desserts")
        }
        .task {
            await viewModel.fetchMeals()
        }
    }
}

/// Individual row view for a meal in the list
struct MealRow: View {
    let meal: Meal

    var body: some View {
        HStack {
            ImageLoadingView(url: meal.thumbnailURL)
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(meal.name)
        }
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView()
    }
}
