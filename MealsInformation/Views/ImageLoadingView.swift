//
//  ImageLoadingView.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/28/24.
//

import Foundation
import SwiftUI

/// View for displaying loaded images with loading and error states
struct ImageLoadingView: View {
    @StateObject private var viewModel: ImageLoadingViewModel

    init(url: String?) {
        _viewModel = StateObject(wrappedValue: ImageLoadingViewModel(url: url))
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                image
                    .resizable()
            } else if viewModel.error != nil {
                Image(systemName: "photo")
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetch()
            }
        }
    }
}
