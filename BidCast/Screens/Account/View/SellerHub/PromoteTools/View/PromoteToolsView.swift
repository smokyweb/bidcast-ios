//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


import SwiftUI
import SVProgressHUD
import AlertToast

// MARK: - Inventory Segment Enum
enum PromoteToolsSegment: String, CaseIterable, CustomStringConvertible {
    case overview = "Overview"
    case promotedShows = "Promoted Shows"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    static var inventorytArray: [String] {
        return PromoteToolsSegment.allCases.map { $0.rawValue }
    }
    
    // Get segment by index
    static func segment(at index: Int) -> PromoteToolsSegment? {
        let allSegments = PromoteToolsSegment.allCases
        guard allSegments.indices.contains(index) else {
            return nil
        }
        return Array(allSegments)[index]
    }
    
    // Get index of current segment
    var index: Int {
        return Array(PromoteToolsSegment.allCases).firstIndex(of: self) ?? 0
    }
}
struct MetricItem {
    var title: String
    var value:String
    var description: String
}

struct PromoteToolsView: View {
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode
    @State var segment: PromoteToolsSegment = .overview
    
    var options:[String] = ["Last 30 days", "Last 3 months", "Last 6 months", "Last year"]
    
    @State private var selectedIndex: Int = 0
    @StateObject private var viewModel = PromoteToolsViewModel()
    @State var promoteToolDetail = AnalyticsData()
    
    var body: some View {
        NavigationView {
                VStack(spacing: 0) {
                    // Header with Back Button and Title
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.custom(poppinsBold, size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Promote Tools")
                            .font(.system(size: 22, weight: .bold))
                        
                        Spacer()
                        
                        // Invisible spacer for centering
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    ScrollView {
                        GenericTabView(selectedTab: $segment) {}
                        if segment == .promotedShows {
                            PromoteShowsScreen()
                        }
                        else  {
                            VStack(spacing: 12) {
                                InfoCard(
                                    title: "Promote Tools",
                                    description: "Promote your livestreams to reach a wider audience on Bidcast."
                                )
                                PillsSelectorView(
                                    titles: options,
                                    selectedIndex: $selectedIndex,
                                    backgroundStyle: .roundedRect,
                                    underlineEnabled: false,
                                    showFilterButton: false,
                                    showSortDropdown: false,
                                    onSelectionChanged: { index, title in
                                        // Show sort sheet when "Sort" is tapped
                                        if index == 0 {
                                            
                                        }
                                        else if index == 1 {
                                            
                                        }
                                        else if index == 2 {
                                            
                                        }
                                    })
                                
                                VStack(spacing: 0) {
                                    // One Promotion, Two Benefits Card
                                    BenefitsCard()
                                }
                                .padding(.horizontal, 12)
                                
                            }
                            
                            // Audience Reached
                            VStack(spacing: 12) {
                                
                                SectionHeaderView(title: "Audience Reached")
                                MetricCardLarge(
                                    title: "Number of Show Boosts",
                                    value: "\(promoteToolDetail.number_of_boost ?? 0)",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Number of Show Promotions",
                                    value: "\(promoteToolDetail.number_of_show_promote ?? 0)",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Community Boosts",
                                    value: "\(promoteToolDetail.community_boost ?? 0)",
                                    description: "The total number of Community Boosts buyers unlocked during your shows."
                                )
                                
                                MetricCardLarge(
                                    title: "Impressions",
                                    value: "\(promoteToolDetail.impressions ?? 0)",
                                    description: "The total number of times a Whatnot user saw your livestreams in their feeds due to a promotion."
                                )
                                
                                MetricCardLarge(
                                    title: "Number of promoted hours",
                                    value: promoteToolDetail.promote_hours ?? "",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Promoted impressions per hour",
                                    value: "\(promoteToolDetail.impression_per_hours ?? 0)",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                // Pro Tips
                                ProTipCard(
                                    text: "Pro Tip: Running longer promotions through Show Promote is more cost-efficient and offers the most sustained increase in discoverability."
                                )
                                
                                SectionHeaderView(title: "Discovery Impact")
                                
                                MetricCardLarge(
                                    title: "Total Taps and Clicks",
                                    value: "214",
                                    description: "Number of users that tapped into your livestream to view your show as a result of your promotions"
                                )
                                
                                MetricCardLarge(
                                    title: "CTR (Click Through Rate)",
                                    value: "12.9%",
                                    description: "Percentage of time your promotions in feeds resulted in a buyer entering your show (taps and clicks)"
                                )
                                
                                MetricCardLarge(
                                    title: "Sustained Watches",
                                    value: "34",
                                    description: "Number of users that clicked into your stream and stayed to watch your show for longer than 30 seconds"
                                )
                                
                                MetricCardLarge(
                                    title: "Sustained Watch Rate",
                                    value: "11.49%",
                                    description: "The percentage of visitors from promotions that converted into sustained viewers"
                                )
                                
                                MetricCardLarge(
                                    title: "Follows from Promotion",
                                    value: "\(promoteToolDetail.follows_from_promotion ?? 0)",
                                    description: "Number of buyers that followed your account by finding you via promotions"
                                )
                                
                                
                                ProTipCard(
                                    text: "Pro Tip: Improve your promotion CTR by experimenting with different titles and thumbnails to make your livestream tile more compelling to browsers.")
                                
                                ProTipCard(
                                    text: "Pro Tip: Increase Sustained Watches: Keep the potential buyers in the room once they enter. Consider always having an item or auction pinned, or engaging more with your audience.")
                                
                                ProTipCard(
                                    text: "Pro Tip: Follow Rate: Remember to remind your viewers to follow you while you are selling. Use the opportunity to tell them what to expect from future shows.")
                                
                            }
                            .padding(12)
                            .background(Color(UIColor.systemBackground))
                            
                            //                    // Content
                            //                    VStack(spacing: 12) {
                            //
                            //                    }
                            //                    .padding(12)
                            //                    .background(Color(UIColor.systemBackground))
                            //
                            // Audience Reached
                            VStack(spacing: 12) {
                                SectionHeaderView(title: "Buyers Converted")
                                
                                MetricCardLarge(
                                    title: "First Time Buyers from Promotion",
                                    value: "N/A",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Direct Sales from Promotion",
                                    value: promoteToolDetail.direct_sales_form_promotion ?? "",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Spend",
                                    value: "N/A",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Immediate Return on Spend",
                                    value: "N/A",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "7-Day Return on Spend",
                                    value: "N/A",
                                    description: "Run a few more promotions to start seeing results for this metric!"
                                )
                                
                                MetricCardLarge(
                                    title: "Bids from Promotion",
                                    value: "3",
                                    description: "The number of bids from buyers who found your show via promotion"
                                )
                                
                                ProTipCard(
                                    text: "Pro Tip: A buyer who makes a purchase in your show is more likely to be recommended your show in the future by our discovery algorithm. Consider using tools like Rewards Club to keep them engaged.")
                                
                                ProTipCard(
                                    text: "Pro Tip: Extra bidders in the room are valuable (even if they don't directly generate sales), as they provide engagement, boost the order value, and also benefit your discoverability.")
                            }
                            .padding(12)
                            .background(Color(UIColor.systemBackground))
                        }
                        
                    }
            }
            .background(.backGround)
            .navigationBarHidden(true)
            .onFirstAppear {
                Task{
                    SVProgressHUD.show()
                    await viewModel.getPromoteToolDetails(param: promoteToolRequest(filter:"all"))
                    await SVProgressHUD.dismiss()
                    if self.viewModel.errorMessage == nil || viewModel.errorMessage == ""{
                        success()
                    }
                }
            }
        }
    }
    
    func success(){
        let response  = viewModel.promoteDetailResponse
        if response.status == "success"{
            promoteToolDetail = response.data ?? AnalyticsData()
        }
    }
}

struct MetricCardLarge: View {
    let title: String
    var value: String? = nil
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.black)
            
            if let value = value {
                Text(value)
                    .font(.custom(poppinsBold, size: 24))
                    .foregroundColor(.black)
            }
            
            Text(description)
                .font(.system(size: 14))
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

struct InfoCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.black)
            
            Text(description)
                .font(.custom(poppinsMedium, size: 14))
                .foregroundColor(Color(UIColor.darkGray))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

struct BenefitsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("One Promotion, Two Benefits")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 14) {
                BenefitRow(
                    title: "Instant audience boost:",
                    description: "Promotions bring more viewers to your live show."
                )
                
                BenefitRow(
                    title: "Long-term discoverability:",
                    description: "More engagement today powers our algorithms to surface your future shows higher in buyers' feed."
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom(poppinsBold, size: 18))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}


struct BenefitRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 1)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            + Text(" " + description)
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.darkGray))
        }
        .fixedSize(horizontal: false, vertical: true)
        .lineSpacing(2)
    }
}


struct ProTipCard: View {
    let text: String
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.defaultTheme.opacity(0.2), Color.defaultTheme.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.orange.opacity(0.25), radius: 6, x: 0, y: 3)
                
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Pro Tip:")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.black)
                
                Text(text)
                    .font(.custom(poppinsMedium, size: 12))
                    .foregroundColor(Color(UIColor.darkGray))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

struct GenericTabView<T>: View where T: CaseIterable & Hashable & RawRepresentable, T.RawValue == String {

    @Binding var selectedTab: T
    var onTabChange: (() -> Void)? = nil
    var tabWidth: CGFloat = 120
    var selectedColor: Color = .defaultTheme
    var unselectedColor: Color = .gray
    
    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 0) {
                ForEach(Array(T.allCases), id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                            onTabChange?()
                        }
                    }) {
                        VStack(spacing: 8) {

                            // Title
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: selectedTab == tab ? .bold : .semibold))
                                .foregroundColor(selectedTab == tab ? selectedColor : unselectedColor)

                            // Indicator
                            Rectangle()
                                .fill(selectedTab == tab ? selectedColor : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        }
//                        .frame(width: tabWidth)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(.backGround)

            Divider()
        }
        .background(.backGround)
    }
}

//struct PromoteToolsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PromoteToolsView()
//    }
//}






//import SwiftUI
//import SVProgressHUD
//
//struct PromoteToolsView: View {
//
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showError: Bool = false
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showhud: Bool = false
//    @State private var hudMsg: String = ""
//    @State private var navigateToLesson = false
//
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @StateObject private var viewModel = PromoteToolsViewModel()
//    @State private var promoteToolData = PromoteToolModel()
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            PrimaryHeader(
//                title: AppString.Promote,
//                isForBoth: false,
//                leadingImgArr: [.icBack,.appName],
//                trailingImgArr: [.icSetting],
//                onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                },
//                count: .constant(0)
//            )
//
//            // Scrollable Content
//            ScrollView {
//                VStack(spacing: 24) {
//
//                    // Top Banner
//                    HStack {
//                        AsyncImage(url: URL(string: promoteToolData.showIcon ?? "")) { image in
//                            image.resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                        } placeholder: {
//                            ProgressView()
//                                .frame(width: 50, height: 50)
//                        }
//
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(promoteToolData.showTitle ?? "")
//                                .font(.custom(poppinsSemiBold, size: 20.0))
//                                .fontWeight(.semibold)
//                            Text(promoteToolData.showDetails ?? "")
//                                .font(.custom(poppinsRegular, size: 16.0))
//                                .foregroundColor(.darkGray)
//                        }
//                        .padding(.horizontal)
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//
//                    // Stats
//                    if let options = promoteToolData.showOptions {
//                        HStack {
//                            if let shows = options.shows {
//                                StatView(stat: StatItem(label: "Shows", value: "\(shows)"))
//                            }
//                            if let views = options.views {
//                                StatView(stat: StatItem(label: "Views", value: "\(views)"))
//                            }
//                            if let followers = options.followers {
//                                StatView(stat: StatItem(label: "Followers", value: "\(followers)"))
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//
//
//                    // Tools Grid
//                    if promoteToolData.features?.count != 0{
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                            ForEach(0 ..< (promoteToolData.features?.count ?? 0), id: \.self) { index in
//                                let feature = promoteToolData.features?[index] ?? Feature()
//                                ToolGridItemView(feature: feature)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//
////                    .padding(.horizontal)
//
//                    // Learn Section
//                    VStack(spacing: 12) {
//                        Text(promoteToolData.promoteTitle ?? "")
//                            .font(.custom(poppinsSemiBold, size: 16.0))
//                            .foregroundColor(.white)
//                        Text(promoteToolData.promoteDetails ?? "")
//                            .font(.custom(poppinsSemiBold, size: 16.0))
//                            .foregroundColor(.white.opacity(0.9))
//                        Button(action: { navigateToLesson = true }) {
//                            Text(AppString.startLearning)
//                                .font(.custom(poppinsSemiBold, size: 13.0))
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.white)
//                                .foregroundColor(.defaultTheme)
//                                .cornerRadius(10)
//                        }
//                    }
//                    .padding()
//                    .background(.defaultTheme)
//                    .cornerRadius(20)
//                    .padding(.horizontal)
//                }
//            }
//            .padding(.top , 15)
//        }
//        .onFirstAppear {
//            Task { await loadData() }
//        }
//        CusNavLink(doNavigate: $navigateToLesson, destination: LessonScreen(backToTabBar:.constant(true),comeFromAccount: true))
//    }
//
//    // MARK: Load API
//    func loadData() async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.getPromoteToolContent()
//        await SVProgressHUD.dismiss()
//
//        if viewModel.promoteToolResponse.status != "success" {
//            alertType = .sheetType(
//                icon: .alert,
//                title: "Error",
//                message: viewModel.promoteToolResponse.message ?? "Something went wrong.",
//                primaryBtnText: "",
//                secondaryBtnText: "OK",
//                sheetThemeColor: .pinkBtn
//            )
//            withAnimation(.snappy) { showError = true }
//        } else {
//            promoteToolData = viewModel.promoteToolResponse.data ?? PromoteToolModel()
//        }
//    }
//}

// MARK: - Shows Screen View
struct PromoteShowsScreen: View {
    
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var isLive = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State var navigateToReherseal = false
    @State var navigateToShowAnalytics = false
    @State private var isActiveOnShowsScreen = false
    
    @State var viewModel = ProfileViewModel()
    @State var showsData = [GetMyScheduleShowModel]()
    
    @State private var selectedProductIds: [String] = []
    @State var selectedShowsData = HomeModel()
    @State var showID = ""
    @State var SHowId = 0
    @State var navigateToshowTitle = false
    
    @State private var scheduleRequest = StoreScheduleShowRequest(
        title: "",
        date: "",
        time: "",
        category_id: "",
        auction_type_id: "",
        product_ids: [],
        is_explicit: false,
        show_discoverability: "",
        repeat_value: "",
        is_repeat: false,
        language: "english"
    )

    // Sample data
//    let shows = [
//        Show(title: "MTG Cards Sale", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156),
//        Show(title: "Show Name", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156)
//    ]

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 10) {
                    if showsData.isEmpty {
                        NoDataView(message: "No Promote Shows found")
                    } else {
                        ForEach(showsData.indices,id: \.self) { index in
                            let data = showsData[index]
                            ShowPromotedShowCardView(show: data)
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
//            CusNavLink(doNavigate: $navigateToReherseal,
//                       destination: RehearsalScreen(showUd: $showID,
//                                                    productListData: .constant([]),
//                                                    isLive: isLive,
//                                                    backToTabBar: .constant(true),
//                                                    showsData: $selectedShowsData))
//            CusNavLink(doNavigate: $navigateToShowAnalytics,
//                       destination:  MyShowsAnalyticsScreen(showId: $showID))
//            
//            CusNavLink(doNavigate: $navigateToshowTitle, destination:
//                        ShowTitleTips(request : $scheduleRequest,
//                                      fromPrepare:.constant(false),
//                                      backToPrepare: $navigateToshowTitle,
//                                      showId: $SHowId))
           
        }
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
        .background(.clear)
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear{
            Task {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "promoted", page : 1))
                await SVProgressHUD.dismiss()
                scheduleShowSuccess()
            }
        }
    }
    
    //MARK: scheduleShowSuccess.
    func scheduleShowSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.getMyScheduleShowResponseDict
        if response?.status == "success" {
            showsData = response?.data ?? []
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    
}


// MARK: - Show Promoted Show Card View
struct ShowPromotedShowCardView: View {
    let show: GetMyScheduleShowModel?
    var onTap: () -> Void
    var onTapMenu: () -> Void
    
    // Initialize with default empty closures
    init(
        show: GetMyScheduleShowModel?,
        onTap: @escaping () -> Void = {},
        onTapMenu: @escaping () -> Void = {}
    ) {
        self.show = show
        self.onTap = onTap
        self.onTapMenu = onTapMenu
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail Image
            thumbnailView
            
            // Content
            contentView
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Thumbnail View
    private var thumbnailView: some View {
        CustomProfileImage(
            url: show?.imgThumbnail?.first ?? "",
            isCircular: false,
            size: 70
        )
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            titleView
            
            // Category
            categoryView
            
            // Sales and Orders
            salesOrdersView
            
            // Date and Time
            dateTimeView
        }
    }
    
    // MARK: - Title View
    private var titleView: some View {
        Text(show?.title?.capitalizingFirstLetter() ?? "")
            .font(.custom(poppinsBold, size: 14))
            .foregroundColor(.primary)
            .lineLimit(2)
    }
    
    // MARK: - Category View
    private var categoryView: some View {
        Text(show?.category?.name ?? "")
            .font(.custom(poppinsSemiBold, size: 13))
            .foregroundColor(.secondary)
    }
    
    // MARK: - Sales and Orders View
    private var salesOrdersView: some View {
        HStack(spacing: 12) {
            // Sales
            HStack(spacing: 4) {
                Text("\(formatCurrency(Int(show?.totalSalesAmount ?? 0.0))) Sales")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
                Text("•")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
                Text("\(show?.totalOrders ?? 0) Orders")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Date and Time View
    private var dateTimeView: some View {
        HStack(spacing: 12) {
            // Date
            HStack(spacing: 4) {
                Text(show?.date ?? "")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
                Text("•")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
                Text(formatTo12HourTime(show?.time ?? ""))
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Int) -> String {
        let num = Double(amount)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return "$\(formatter.string(from: NSNumber(value: num)) ?? "0.00")"
    }
}
