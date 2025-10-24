//
//  SearchViewModel.swift
//  BidCast
//
//  Created by JamTech on 18/10/25.
//

import Foundation
import Combine

class SearchTextViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()

    init(onDebouncedSearch: @escaping (String) -> Void) {
        $searchText
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { text in
                onDebouncedSearch(text)
            }
            .store(in: &cancellables)
    }
}
