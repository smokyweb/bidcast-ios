//
//  SearchViewModel.swift
//  BidCast
//
//  Created by JAM-E-265 on 02/02/24.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    
    @Published var shows: [Show] = []
    @Published var products: [Product] = []
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func search(query: String, page: Int = 1) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Clear results if query is empty
            self.shows = []
            self.products = []
            self.users = []
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        let params = UnifiedSearchRequest(search: query, page: String(page))
        
        APIManager.shared.request(
            modelType: UnifiedSearchResponse.self,
            type: .unifiedSearch(param: params)
        )
        .sink { completion in
            self.isLoading = false
            switch completion {
            case .failure(let error):
                self.errorMessage = "Failed to fetch search results: \(error.localizedDescription)"
            case .finished:
                break
            }
        } receiveValue: { response in
            self.shows = response.data.shows
            self.products = response.data.products
            self.users = response.data.users
        }
        .store(in: &cancellables)
    }
}
