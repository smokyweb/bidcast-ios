//
//  SearchViewModel.swift
//  BidCast
//
//  Created by Vivek_JAM-E_328 on 18/10/25.
//

import Foundation
import Combine

class SearchTextViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()

    init(onDebouncedSearch: @escaping (String) -> Void) {
        // MC cmpewtofs000msahgns50t4yk (Robin 2026-05-22): drop the
        // initial "" emission. @Published emits its current value to
        // every new subscriber, so without dropFirst the Combine chain
        // fires `onDebouncedSearch("")` ~1 sec after every SearchBarView
        // first appears — which causes the consumer (e.g.
        // ExploreViewScreen.fetchCategory, InventoryScreen reload,
        // MyOrdersScreen reload, ProfileScreen shop reload) to re-run
        // an unnecessary fetch on every screen appearance, producing
        // the 1–2s-after-tab-switch shimmer flash Larry reported on
        // Home/Explore/Activity (2026-05-22 12:58 EDT screenshot).
        //
        // dropFirst skips only the subscribe-time current value; every
        // subsequent user-typed change still propagates normally.
        $searchText
            .dropFirst()
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { text in
                onDebouncedSearch(text)
            }
            .store(in: &cancellables)
    }
}
