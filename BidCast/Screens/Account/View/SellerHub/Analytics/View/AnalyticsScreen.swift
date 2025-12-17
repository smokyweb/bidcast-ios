//
//  AnalyticsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import Charts
import SVProgressHUD
import AlertToast

struct AnalyticsScreen: View {
    let stats: [StatItem] = [
        StatItem(label: AppString.Shows, value: "284"),
        StatItem(label: AppString.Views, value: "12.4k"),
        StatItem(label: AppString.Followers, value: "892")
    ]

    var sellerAlytics: [TipSummaryItem] {
        guard let summary = sellerAnalyticsData?.stats else { return [] }
        
        return [
            TipSummaryItem(title: "Items", value: "\(summary.totalItems ?? 0)"),
            TipSummaryItem(title: "Revenue", value: "$ \(summary.revenue ?? "0")"),
            TipSummaryItem(title: "Rating", value: "\(summary.rating ?? 0)")
        ]
    }
    
    @State private var navigateToLesson = false
    @State var segment : AnalyticsSegment = .overall
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = SellerAnalyticsViewModel()
    
    @State var visitorsAnalyticsData: VisitorsAnalyticsModel?
    @State var sellerAnalyticsData: SellerAnalyticsModel?
    @State var salesPerformanceData: SalesPerformanceModel?
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @StateObject private var downloadManager = CSVDownloadManager.shared
    
    @State var salesData: [ChartData] = []
    @State var visitorsData : [ChartData] = []
    
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showDatePicker = false
    @State private var showMetricsInfo = false
    @State var topBuyers: [TopBuyerBySales] = []
    @State var topOrders: [TopBuyerByOrders] = []
   
    @State private var exportRequest: SellerAnalyticsRequest?
    
    struct ToolItem: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
        let subtitle: String
        let iconColor: Color
    }

    var tools: [ToolItem] {
        guard let summary = sellerAnalyticsData?.stats else { return [] }
        
        return [
            ToolItem(iconName: "person.3.fill",
                     title: AppString.totalFollowers,
                     subtitle: "\(summary.followers ?? 0)",
                     iconColor: .defaultTheme),
            ToolItem(iconName: "star.fill",
                     title: AppString.averageRating,
                     subtitle: "\(summary.rating ?? 0)",
                     iconColor: .defaultTheme),
            ToolItem(iconName: "video.fill",
                     title: AppString.liveSession,
                     subtitle: "\(summary.liveSessions ?? 0)",
                     iconColor: .defaultTheme),
            ToolItem(iconName: "cart.fill",
                     title: AppString.TotalSales,
                     subtitle: "\(summary.totalSales ?? 0)",
                     iconColor: .defaultTheme)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed PrimaryHeader at the top
            VStack{
                PrimaryHeader(
                    title: AppString.Analytics,
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
            // Scrollable content below the header
            ScrollView {
                VStack(spacing: 8) {
                    
                    ListCell(image: sellerAnalyticsData?.seller?.profile ?? "",
                             title: sellerAnalyticsData?.seller?.name ?? "" ,
                             subLabel: "Seller since \(sellerAnalyticsData?.seller?.since ?? "")",
                             isVectorImgHidden: true)
                        .padding(.bottom,1)
                        .frame(height: 80)
                        .padding(.horizontal , 16)
                    
                    CustomSegmentedControl(preselectedIndex: $segment ,
                                           options: AnalyticsSegment.allCases)
                    .padding(.horizontal , 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SellerAnalyticsHeaderView(
                            startDate: $startDate,
                            endDate: $endDate,
                            onPreviousPeriod: {
                                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 14
                                startDate = Calendar.current.date(byAdding: .day, value: -days, to: startDate) ?? startDate
                                endDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
                                
                                Task {
                                    let request = SellerAnalyticsRequest(
                                        filter: "custom",
                                        start_date: ISO8601DateFormatter().string(from: startDate),
                                        end_date: ISO8601DateFormatter().string(from: endDate)
                                    )
                                    await fetchSellerAnalyticsAsync(using: request)
                                }
                            },
                            onNextPeriod: {
                                
                                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 14
                                startDate = Calendar.current.date(byAdding: .day, value: days, to: startDate) ?? startDate
                                endDate = Calendar.current.date(byAdding: .day, value: days, to: endDate) ?? endDate
                                
                                
                                if endDate > Date() {
                                    endDate = Date()
                                }
                                
                                Task {
                                    let request = SellerAnalyticsRequest(
                                        filter: "custom",
                                        start_date: ISO8601DateFormatter().string(from: startDate),
                                        end_date: ISO8601DateFormatter().string(from: endDate)
                                    )
                                    await fetchSellerAnalyticsAsync(using: request)
                                }
                            },
                            onEditDates: {
                                showDatePicker = true
                            },
                            onShowMetricsInfo: {
                                showMetricsInfo = true
                            }
                        )
                        .padding(.horizontal,16)
                        
                        priceCardView(amount: "00.00", label: "Estimated sales", onMoreTapped: {
                            
                        })
                        .padding(.horizontal, 16)
                        
                        VStack(spacing: 16) {
                            ToolGridAnalyticsView(
                                title: AppString.SalePerformance,
                                chartData: salesData,
                                chartType: .bar
                            ) { filter in
                                Task {
                                    let request = SellerAnalyticsRequest(
                                        filter: filter
                                    )
                                    await fetchSellerAnalyticsAsync(using: request)
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        Text("Who is watching my live shows?")
                            .font(.custom(poppinsBold, size: 16.0))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                        
                        TopBuyersBySalesCard(
                            title: "Top Buyers by Sales",
                            buyers: topBuyers, orders: topOrders,
                             onExportData: {
                                 let type = "sale"
                                 Task {
                                     await downloadToFiles(type: type)
                                 }
                             }, forBuyers: true
                         )
                         .padding(.horizontal,16)
                        
                        TopBuyersBySalesCard(
                            title: "Top Buyers by Orders",
                            buyers: topBuyers, orders: topOrders,
                             onExportData: {
                                 let type = "order"
                                 Task {
                                     await downloadToFiles(type: type)
                                 }
                             },forBuyers: false
                         )
                         .padding(.horizontal,16)
                        
                    }
//                        .padding(.horizontal)
                        .padding(.top,10)
                        
                        // Tools Grid
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                            ForEach(tools) { tool in
//                                ToolGridItemsView(tool: tool)
//                            }
//                        }
//                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
        .onAppear {
            Task {
                let visitorsRequest = VisitorsAnalyticsRequest(filter: "yearly", year: "2025", month: nil)
                let sellerRequest = SellerAnalyticsRequest(filter: "yearly", start_date: nil, end_date: nil)
                let salesRequest = SalesPerformanceRequest(filter: "yearly", year: "2025", month: nil)
                async let visitors: () = fetchVisitorsAnalyticsAsync(using: visitorsRequest)
                async let seller: () = fetchSellerAnalyticsAsync(using: sellerRequest)
                async let sales: () = fetchSalesPerformanceAsync(using: salesRequest)
                
                // Await all of them to finish
                await visitors
                await seller
                await sales
            }
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .sheet(isPresented: $showDatePicker) {
            DateRangePickerView(startDate: $startDate, endDate: $endDate) {
                Task {
                    let request = SellerAnalyticsRequest(
                        filter: "custom",
                        start_date: ISO8601DateFormatter().string(from: startDate),
                        end_date: ISO8601DateFormatter().string(from: endDate)
                    )
                    await fetchSellerAnalyticsAsync(using: request)
                }
            }
        }
        .sheet(isPresented: $showMetricsInfo) {
//            MetricsInfoView()
        }
    }
    
    struct ToolGridItemsView: View {
        let tool: ToolItem

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: tool.iconName)
                    .font(.custom(poppinsSemiBold, size: 16.0))
                    .foregroundColor(tool.iconColor)
                Text(tool.title)
                    .font(.custom(poppinsSemiBold, size: 16.0))
                Text(tool.subtitle)
                    .font(.custom(poppinsRegular, size: 14.0))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    func fetchVisitorsAnalyticsAsync(using request: VisitorsAnalyticsRequest) async {
        await performAPICalls(
            isConcurrent: true,
            showLoader: true,
            onError: { error in
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }, onSuccess: {
                // On success
                visitorsSuccess()
            }
            
        ) {
            try await viewModel.getVisitorsAnalyticsReport(request: request)
        }
        
    }

    func fetchSellerAnalyticsAsync(using request: SellerAnalyticsRequest) async {
            await performAPICalls(
                isConcurrent: true,
                showLoader: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }, onSuccess: {
                    // On success
                    sellerSuccess()
                }
                
            ) {
                exportRequest = request
                try await viewModel.getSellerAnalyticsReport(request: request)
            }
    }
    
//    func exportDetails(using type: String) async {
//        await performAPICalls(
//            isConcurrent: true,
//            showLoader: true,
//            onError: { error in
//                alertType = .sheetType(
//                    icon: .alert,
//                    title: "Error",
//                    message: errorDesc(error: error, message: viewModel.errorMessage),
//                    primaryBtnText: "",
//                    secondaryBtnText: AppString.ok.localized
//                )
//                showError = true
//            }, onSuccess: {
//                // On success
//                sellerSuccess()
//            }
//            
//        ) {
//            let request = ExportDetailsRequest(filter: exportRequest?.filter ?? "",
//                                               start_date: exportRequest?.start_date ?? "",
//                                               end_date: exportRequest?.end_date ?? "",
//                                               type: type
//            )
//            try await viewModel.getExportDetailsReport(request: request)
//        }
//    }
    
    private func downloadToFiles(type: String) async {
        do {
            let fileName = "sales_report_\(formatDate(Date())).csv"
            
            let request = ExportDetailsRequest(filter: exportRequest?.filter ?? "",
                                               start_date: exportRequest?.start_date ?? "",
                                               end_date: exportRequest?.end_date ?? "",
                                               type: type
            )
            
            let fileURL = try await downloadManager.downloadCSV(
                request: request,
                endPoint: APIEndPoint.getExportDetails(param: request),
                fileName: fileName,
                saveLocation: .downloads
            )
            
            await MainActor.run {
                hudMsg = "File saved successfully"
                showhud = true
                //                  loadDownloadedFiles()
            }
            
        } catch {
            await MainActor.run {
                hudMsg = "Download Failed"
                showhud = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd_HHmmss"
           return formatter.string(from: date)
       }

    func fetchSalesPerformanceAsync(using request: SalesPerformanceRequest) async {
        await performAPICalls(
            isConcurrent: true,
            showLoader: true,
            onError: { error in
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }, onSuccess: {
                // On success
                salesSuccess()
            }
            
        ) {
            try await viewModel.getSalesPreformanceReport(request: request)
        }
    }
    
    func visitorsSuccess(){
        let response = viewModel.visitorsAnalyticsResponse
        if response?.status == "success"{
            visitorsAnalyticsData = response?.data
            if let charts = visitorsAnalyticsData?.chart {
                for item in charts {
                    visitorsData.append(ChartData(month: item.label ?? "",
                                               value: Int(item.totalVisitors ?? "0") ?? 0))
                }
            }
        }else{
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
    
    func sellerSuccess() {
        let response = viewModel.sellerAnalyticsResponse
        if response?.status == "success"{
            sellerAnalyticsData = response?.data
            topBuyers = sellerAnalyticsData?.top_buyers_by_sales ?? []
            topOrders = sellerAnalyticsData?.top_buyers_by_orders ?? []
        }else{
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
    
    func salesSuccess() {
        let response = viewModel.salesPerformanceResponse
        if response?.status == "success"{
            salesPerformanceData = response?.data
//            salesData.append(ChartData(month: "February",
//                                       value: 12))
//            salesData.append(ChartData(month: "March",
//                                       value: 14))
//            salesData.append(ChartData(month: "April",
//                                       value: 16))
//            salesData.append(ChartData(month: "May",
//                                       value: 12))
//            salesData.append(ChartData(month: "June",
//                                       value: 22))
            if let charts = salesPerformanceData?.chart {
                for item in charts {
                    salesData.append(ChartData(month: item.label ?? "",
                                               value: item.totalSales ?? 0))
                }
            }
        }else{
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }

}


//MARK: AnalyticsSegment
enum AnalyticsSegment : String, CaseIterable, CustomStringConvertible{
    case overall = "Overall"
    case livestream = "Livestream"
    case promote = "Promote"
//    case trust = "Trust"
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "").localized
    }
}

struct ChartData: Identifiable {
    var id = UUID()
    var month: String
    var value: Int
    
}

struct BarChartView: View {
    let data: [ChartData]

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Month", item.month),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.blue.opacity(0.5))
                .cornerRadius(5) // Rounded corners
                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 2)
                
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 150)
        .padding()
    }
}

struct AreaChartView: View {
    let data: [ChartData]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                AreaMark(
                    x: .value("Month", item.month),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.blue.opacity(0.5))
                .cornerRadius(5) // Rounded corners
                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 2)
                
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 150)
        .padding()
    }
}

struct DateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onApply: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                Button(action: {
                    onApply()
                    dismiss()
                }) {
                    Text("Apply")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
struct MetricsInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    let metrics = [
        ("Total Followers", "The total number of users following your seller account"),
        ("Average Rating", "Your average customer rating based on all reviews"),
        ("Live Sessions", "Total number of live streaming sessions conducted"),
        ("Total Sales", "Total number of items sold across all sessions"),
        ("Revenue", "Total revenue generated from sales"),
        ("Items", "Total number of items listed")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(metrics, id: \.0) { metric in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(metric.0)
                                .font(.custom(poppinsSemiBold, size: 16))
                                .foregroundColor(.black)
                            
                            Text(metric.1)
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Metrics Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SellerAnalyticsHeaderView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var onPreviousPeriod: () -> Void
    var onNextPeriod: () -> Void
    var onEditDates: () -> Void
    var onShowMetricsInfo: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text("Seller Analytics")
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.black)
            
            // Date Range and Navigation
            HStack {
                Text("\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Left Arrow Button
                    Button(action: onPreviousPeriod) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    Button(action: onNextPeriod) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onEditDates) {
                    Text("Edit Dates")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.defaultTheme)
                        .cornerRadius(20)
                }
                Spacer()
                
                // What do these metrics mean Button
                Button(action: onShowMetricsInfo) {
                    Text("What do these metrics mean?")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.defaultTheme)
                }
                
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 2)
    }
}
