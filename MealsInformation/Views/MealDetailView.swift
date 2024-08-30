//
//  MealDetailView.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import SwiftUI

struct MealDetailView: View {
    let mealName: String
    @StateObject private var viewModel: MealDetailViewModel
    
    /// Enum to manage the segmented control for ingredients and instructions
    private enum Section: String, CaseIterable {
        case ingredients = "Ingredients"
        case instructions = "Instructions"
    }
    
    @State private var selectedSection: Section = .ingredients
    
    init(mealId: String, mealName: String) {
        self.mealName = mealName
        _viewModel = StateObject(wrappedValue: MealDetailViewModel(mealId: mealId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                mealImage
                sectionPicker
                selectedSectionContent
            }
            .padding()
        }
        .navigationTitle(mealName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMealDetail()
        }
    }
    
    /// Meal image or placeholder
    @ViewBuilder
    private var mealImage: some View {
        if let mealDetail = viewModel.mealDetail {
            ImageLoadingView(url: mealDetail.thumbnailURL)
                .scaledToFill()
                .frame(height: 300)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
        } else {
            Image(systemName: "photo")
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /// Segmented control for section selection
    private var sectionPicker: some View {
        Picker("Section", selection: $selectedSection) {
            ForEach(Section.allCases, id: \.self) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical)
    }
    
    /// Content based on selected section (ingredients or instructions)
    @ViewBuilder
    private var selectedSectionContent: some View {
        if viewModel.mealDetail != nil {
            switch selectedSection {
            case .ingredients:
                ingredientsList
            case .instructions:
                instructionsList
            }
        }
    }

    /// List of ingredients
    private var ingredientsList: some View {
        ForEach(viewModel.mealDetail?.ingredients.items ?? [], id: \.id) { ingredient in
            HStack(alignment: .top) {
                Text("•")
                Text(ingredient.name)
                Spacer()
                Text(ingredient.measure)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }

    /// Numbered list of instructions
    private var instructionsList: some View {
        ForEach(Array(viewModel.mealDetail?.instructions.enumerated() ?? [].enumerated()), id: \.element) { index, instruction in
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Text(instruction)
                    .font(.body)
            }
            .padding(.vertical, 4)
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealDetailView(mealId: "52910", mealName: "Chinon Apple Tarts")
        }
    }
}
