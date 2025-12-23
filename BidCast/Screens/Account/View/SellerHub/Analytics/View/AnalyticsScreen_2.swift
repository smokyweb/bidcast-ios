//
//  AnalyticsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import Charts
import SVProgressHUD

//struct AnalyticsScreen_2: View {
//    let stats: [StatItem] = [
//        StatItem(label: AppString.Shows, value: "284"),
//        StatItem(label: AppString.Views, value: "12.4k"),
//        StatItem(label: AppString.Followers, value: "892")
//    ]
//
//    var sellerAlytics: [TipSummaryItem] {
//        guard let summary = sellerAnalyticsData?.stats else { return [] }
//        
//        return [
//            TipSummaryItem(title: "Items", value: "\(summary.totalItems ?? 0)"),
//            TipSummaryItem(title: "Revenue", value: "$ \(summary.revenue ?? "0")"),
//            TipSummaryItem(title: "Rating", value: "\(summary.rating ?? 0)")
//        ]
//    }
//    
//    @State private var navigateToLesson = false
//    @State var segment : AnalyticsSegment = .overall
//    @Environment(\.presentationMode) var presentationMode
//    
//    @StateObject var viewModel = SellerAnalyticsViewModel()
//    
//    @State var visitorsAnalyticsData: VisitorsAnalyticsModel?
//    @State var sellerAnalyticsData: SellerAnalyticsModel?
//    @State var salesPerformanceData: SalesPerformanceModel?
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    @State var showError: Bool = false
//    
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    
//    @State var salesData: [ChartData] = []
//    @State var visitorsData : [ChartData] = []
//    
//    struct ToolItem: Identifiable {
//        let id = UUID()
//        let iconName: String
//        let title: String
//        let subtitle: String
//        let iconColor: Color
//    }
//
//    var tools: [ToolItem] {
//        guard let summary = sellerAnalyticsData?.stats else { return [] }
//        
//        return [
//            ToolItem(iconName: "person.3.fill",
//                     title: AppString.totalFollowers,
//                     subtitle: "\(summary.followers ?? 0)",
//                     iconColor: .defaultTheme),
//            ToolItem(iconName: "star.fill",
//                     title: AppString.averageRating,
//                     subtitle: "\(summary.rating ?? 0)",
//                     iconColor: .defaultTheme),
//            ToolItem(iconName: "video.fill",
//                     title: AppString.liveSession,
//                     subtitle: "\(summary.liveSessions ?? 0)",
//                     iconColor: .defaultTheme),
//            ToolItem(iconName: "cart.fill",
//                     title: AppString.TotalSales,
//                     subtitle: "\(summary.totalSales ?? 0)",
//                     iconColor: .defaultTheme)
//        ]
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Fixed PrimaryHeader at the top
//            VStack{
//                PrimaryHeader(
//                    title: AppString.Analytics,
//                    isForBoth: false,
//                    leadingImgArr: [.icBack,.appName],
//                    trailingImgArr: [.icSetting],
//                    onClickLeading: { _ in
//                        self.presentationMode.wrappedValue.dismiss()
//                    },
//                    count: .constant(0)
//                )
//            }
//            
//            // Scrollable content below the header
//            ScrollView {
//                VStack(spacing: 8) {
//                    
//                    ListCell(image: sellerAnalyticsData?.seller?.profile ?? "",
//                             title: sellerAnalyticsData?.seller?.name ?? "" ,
//                             subLabel: "Seller since \(sellerAnalyticsData?.seller?.since ?? "")",
//                             isVectorImgHidden: true)
//                        .padding(.bottom,1)
//                        .frame(height: 80)
//                    
//                    CustomSegmentedControl(preselectedIndex: $segment ,
//                                           options: AnalyticsSegment.allCases)
//                    .padding(.horizontal , 16)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        TwoVerticalLabelCell(
//                            dataModel: sellerAlytics,
//                            topLabel: { $0.title },
//                            bottomLabel: { $0.value }
//                        )
//                            
//                            VStack(spacing: 16) {
//                                ToolGridAnalyticsView(
//                                    title: AppString.SalePerformance,
//                                    chartData: salesData,
//                                    chartType: .bar
//                                )
//
//                                ToolGridAnalyticsView(
//                                    title: AppString.VisitorAnalytics,
//                                    chartData: visitorsData,
//                                    chartType: .line
//                                )
//                            }
//                            .padding(.vertical)
//                        }
////                        .padding(.horizontal)
//                        .padding(.top,10)
//                        
//                        // Tools Grid
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                            ForEach(tools) { tool in
//                                ToolGridItemsView(tool: tool)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    .padding(.top)
//                }
//            }
//        .onAppear {
//            Task {
//                let visitorsRequest = VisitorsAnalyticsRequest(filter: "yearly", year: "2025", month: nil)
//                let sellerRequest = SellerAnalyticsRequest(filter: "yearly", start_date: nil, end_date: nil)
//                let salesRequest = SalesPerformanceRequest(filter: "yearly", year: "2025", month: nil)
//                async let visitors: () = fetchVisitorsAnalyticsAsync(using: visitorsRequest)
//                async let seller: () = fetchSellerAnalyticsAsync(using: sellerRequest)
//                async let sales: () = fetchSalesPerformanceAsync(using: salesRequest)
//                
//                // Await all of them to finish
//                await visitors
//                await seller
//                await sales
//            }
//        }
//    }
//    
//    struct ToolGridItemsView: View {
//        let tool: ToolItem
//
//        var body: some View {
//            VStack(alignment: .leading, spacing: 8) {
//                Image(systemName: tool.iconName)
//                    .font(.custom(poppinsSemiBold, size: 16.0))
//                    .foregroundColor(tool.iconColor)
//                Text(tool.title)
//                    .font(.custom(poppinsSemiBold, size: 16.0))
//                Text(tool.subtitle)
//                    .font(.custom(poppinsRegular, size: 14.0))
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .frame(maxWidth: .infinity, minHeight: 100)
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//        }
//    }
//    
//    func fetchVisitorsAnalyticsAsync(using request: VisitorsAnalyticsRequest) async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.getVisitorsAnalyticsReport(request: request) // You need async version of ViewModel call
//        await SVProgressHUD.dismiss()
//        visitorsSuccess()
//    }
//
//    func fetchSellerAnalyticsAsync(using request: SellerAnalyticsRequest) async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.getSellerAnalyticsReport(request: request)
//        await SVProgressHUD.dismiss()
//        sellerSuccess()
//    }
//
//    func fetchSalesPerformanceAsync(using request: SalesPerformanceRequest) async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.getSalesPreformanceReport(request: request)
//        await SVProgressHUD.dismiss()
//        salesSuccess()
//    }
//    
//    func visitorsSuccess(){
//        let response = viewModel.visitorsAnalyticsResponse
//        if response?.status == "success"{
//            visitorsAnalyticsData = response?.data
//            if let charts = visitorsAnalyticsData?.chart {
//                for item in charts {
//                    visitorsData.append(ChartData(month: item.label ?? "",
//                                               value: Int(item.totalVisitors ?? "0") ?? 0))
//                }
//            }
//        }else{
//            showError = true
//            alertType = .sheetType(
//                icon: .alert,
//                title: response?.error_type?.capitalized ?? "",
//                message: response?.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//        }
//    }
//    
//    func sellerSuccess() {
//        let response = viewModel.sellerAnalyticsResponse
//        if response?.status == "success"{
//            sellerAnalyticsData = response?.data
//        }else{
//            showError = true
//            alertType = .sheetType(
//                icon: .alert,
//                title: response?.error_type?.capitalized ?? "",
//                message: response?.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//        }
//    }
//    
//    func salesSuccess() {
//        let response = viewModel.salesPerformanceResponse
//        if response?.status == "success"{
//            salesPerformanceData = response?.data
//            if let charts = salesPerformanceData?.chart {
//                for item in charts {
//                    salesData.append(ChartData(month: item.label ?? "",
//                                               value: item.totalSales ?? 0))
//                }
//            }
//        }else{
//            showError = true
//            alertType = .sheetType(
//                icon: .alert,
//                title: response?.error_type?.capitalized ?? "",
//                message: response?.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//        }
//    }
//
//}


////MARK: AnalyticsSegment
//enum AnalyticsSegment : String, CaseIterable, CustomStringConvertible{
//    case overall = "Overall"
//    case livestream = "Livestream"
//    case promote = "Promote"
//    case trust = "Trust"
//    
//    var description: String {
//        return NSLocalizedString(rawValue, comment: "").localized
//    }
//}
//
//struct ChartData: Identifiable {
//    var id = UUID()
//    var month: String
//    var value: Int
//    
//}
//
//struct BarChartView: View {
//    let data: [ChartData]
//
//    var body: some View {
//        Chart {
//            ForEach(data) { item in
//                BarMark(
//                    x: .value("Month", item.month),
//                    y: .value("Value", item.value)
//                )
//                .foregroundStyle(Color.defaultTheme.opacity(0.5))
//                .cornerRadius(5) // Rounded corners
//                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 2)
//                
//            }
//        }
//        .chartXAxis {
//            AxisMarks(position: .bottom)
//        }
//        .chartYAxis {
//            AxisMarks(position: .leading)
//        }
//        .frame(height: 150)
//        .padding()
//    }
//}
//
//struct AreaChartView: View {
//    let data: [ChartData]
//    
//    var body: some View {
//        Chart {
//            ForEach(data) { item in
//                AreaMark(
//                    x: .value("Month", item.month),
//                    y: .value("Value", item.value)
//                )
//                .foregroundStyle(Color.defaultTheme.opacity(0.5))
//                .cornerRadius(5) // Rounded corners
//                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 2)
//                
//            }
//        }
//        .chartXAxis {
//            AxisMarks(position: .bottom)
//        }
//        .chartYAxis {
//            AxisMarks(position: .leading)
//        }
//        .frame(height: 150)
//        .padding()
//    }
//}
