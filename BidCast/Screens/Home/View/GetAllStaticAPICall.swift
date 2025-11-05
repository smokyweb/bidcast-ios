//
//  GetAllStaticAPICall.swift
//  BidCast
//
//  Created by JamTech on 05/11/25.
//

import Foundation

@MainActor
final class StaticAPIViewModel: ObservableObject {
    
    static let shared = StaticAPIViewModel()  // optional if you want shared instance
    
    @Published var lessons = [LessonModel]()
    @Published var sellingLessons = [LessonModel]()
    
    @Published var isLoading = false

    private var lessonsViewModel = ScheduleViewModel()

    func getAllLessons() async {
        guard isInternetAvailable() else { return }

        isLoading = true
        await lessonsViewModel.getLesson()
        isLoading = false

        if let response = lessonsViewModel.lessonsResponse,
           response.status == "success" {
            lessons = response.data
        } else {
            print("⚠️ API error: \(lessonsViewModel.lessonsResponse?.status ?? "unknown")")
        }
    }
    
    
    // MARK: - Fetch How To Sell Lessons
    func fetchHowToSell() async {
        guard isInternetAvailable() else { return }
        
        isLoading = true
        await lessonsViewModel.getHowToSell()
        isLoading = false
        
        guard let dict = lessonsViewModel.lessonsResponse else {
            print("⚠️ No response received")
            return
        }
        
        if dict.status == "success" {
            sellingLessons = dict.data
            print("✅ Lessons updated successfully")
        } else {
            print("❌ API error: \(dict.status ?? "Unknown error")")
        }
    }

    func isInternetAvailable() -> Bool {
        Reachability.isConnectedToNetwork()
    }
}
