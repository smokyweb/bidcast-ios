//
//  ScheduleViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

//
//  ScheduleViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import Foundation

@MainActor
final class ScheduleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var lessonsResponse: ResponseModal<[LessonModel]>?
    @Published var tipsResponse: ResponseModal<[TitleTipsModel]>?
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""

    // MARK: - Get Lessons
    func getLesson() async {
        requestType = "lesson"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLesson,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Selling Tips
    func getSellingTips() async {
        requestType = "sellingTips"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getSellingTips,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get How To Sell
    func getHowToSell() async {
        requestType = "howToSell"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.howToSell,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Show Tips
    func getShowTips() async {
        requestType = "showTips"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.showTips,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Let's Prepare
    func getLetsPrepare() async {
        requestType = "letsPrepare"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.letsPrepare,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Title Tips
    func getTitleTips(param: TipParam) async {
        requestType = "titleTips"
        do {
            let response: ResponseModal<[TitleTipsModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getAllTips(param: param),
                header: true
            )
            tipsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
