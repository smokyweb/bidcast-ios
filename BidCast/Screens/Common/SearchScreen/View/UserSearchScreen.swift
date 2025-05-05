//import SwiftUI
//import AlertToast
//import BottomSheet
//import Combine
//
//struct UserSearchScreen: View {
//    
//    //MARK: Static Properties
//    @Environment(\.presentationMode) var presentationMode
//    @State var isLoading: Bool = false
//    @State var showError: Bool = false
//    @State var jobList: [JobDetailResponse] = []
//    @State var selectedJob: JobDetailResponse = JobDetailResponse()
//    @State var filterRequest: FilterRequestModal = FilterRequestModal(location: "", job_title: "", company_name: "", job_description: "", category: 0, job_id: 0, salary: "", benefit: "")
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State var searchRequest: SearchRequest = SearchRequest(search: "", type: "search", page: 1)
//    @State var totalPage: Int = 1
//    
//    @State var navigateToJobPost: Bool = false
//    @State var navigateToSelectedJob: Bool = false
//    @State var selectedJobId: String = ""
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    @State var searchText: String = ""
//    
//    @State var showFilterOptions: Bool = false
//    
//    //MARK: Properties
//    var searchViewModel = SearchViewModel()
//    
//    // Debounce Publisher
//    private let searchDebouncePublisher = PassthroughSubject<String, Never>()
//    private var cancellableSet: Set<AnyCancellable> = []
//    
//    init() {
//        setupSearchDebounce()
//    }
//    
//    // Setup debounce mechanism for search
//    private mutating func setupSearchDebounce() {
//        searchDebouncePublisher
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .sink { [self] value in
//                executeSearch(for: value)
//            }
//            .store(in: &cancellableSet)
//    }
//    
//    //MARK: - Primary View Body
//    var body: some View {
//        ZStack {
//            VStack {
//                HeaderWithSearch(
//                    title: "Job Search",
//                    leadingImgArr: [.sideArrow],
//                    onClickLeading: { _ in
//                        self.presentationMode.wrappedValue.dismiss()
//                    },
//                    onSubmitClick: { value in
//                        if value.isEmpty {
//                            hudMsg = "Please enter Job Name to begin search"
//                            showhud = true
//                        } else {
//                            searchRequest.search = value
//                            searchRequest.page = 1
//                            searchRequest.type = "search"
//                            self.searchViewModel.jobSearch(parameter: searchRequest)
//                            withAnimation(.easeIn) { jobList.removeAll() }
//                        }
//                    },
//                    onFilterClick: {
//                        showFilterOptions = true
//                    }
//                )
//                .onChange(of: searchText) { newValue in
//                    searchDebouncePublisher.send(newValue)
//                }
//                
//                ScrollView(showsIndicators: false) {
//                    if jobList.isEmpty {
//                        Text("No Job available for current search filter")
//                            .font(.custom(nunitoMedium, fixedSize: 18))
//                            .foregroundStyle(.gray)
//                            .frame(height: screenHeight * 0.7)
//                    } else {
//                        LazyVStack {
//                            ForEach(Array(jobList.enumerated()), id: \.element.id) { (ind, jobDetail) in
//                                JobListingCard(jobDetail: Binding(
//                                    get: { self.jobList[ind] },
//                                    set: { self.jobList[ind] = $0 }
//                                )) { value in
//                                    selectedJobId = "\(value)"
//                                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                                        if role == "employer" {
//                                            selectedJob = jobList.first(where: { $0.id == jobList[ind].id }) ?? JobDetailResponse()
//                                            
//                                            navigateToSelectedJob = true
//                                        }else{
//                                            navigateToJobPost = true
//                                        }
//                                    }
//                                }
//                                .onAppear(perform: {
//                                    if ind < jobList.count {
//                                        handlePagination(currentData: jobList[ind])
//                                    }
//                                })
//                            }
//                        }
//                      
//                        .padding()
//                    }
//                }
//                
//                .refreshable {
//                    isLoading = true
//                    searchRequest.page = 1
//                    searchRequest.search = ""
//                    self.searchViewModel.jobSearch(parameter: searchRequest)
//                    observe()
//                }
//                Spacer()
//            }
//            .padding(.top, -topPadding)
//            .toast(isPresenting: $showhud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
//            }
//            .bottomSheet(isPresented: $showError, height: screenHeight / 2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = false }, content: {
//                CommonBottomSheet(sheetType: $alertType, onPrimaryClick: { showError = false }, onSecondaryClick: { showError = false })
//            })
//            
//            .sheet(isPresented: $showFilterOptions, content: {
//                if let role:String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                    if role == "employer" {
//                        FilterEmployerOptionView(isJobSearch: true) { result in
//                            showFilterOptions.toggle()
//                            self.searchViewModel.getFilterJobSearch(parameter: result)
//                        }
//                    } else {
//                        FilterOptionView(filterRequest: self.filterRequest, isJobSearch: true) { result in
//                            showFilterOptions.toggle()
//                            filterRequest = result
//                            self.searchViewModel.getFilterSearch(parameter: result)
//                        }
//                    }
//                }
//            })
//            
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//            
//            if let role : String = UserDefaultsManager.shared.value(forKey: .userRole)  {
//                if role == "employer" {
//                    CusNavLink(doNavigate: $navigateToSelectedJob, destination: SelectedJobScreen(jobDetail: $selectedJob))
//                } else {
//                    CusNavLink(doNavigate: $navigateToJobPost, destination: JobPostingScreen(jobId: $selectedJobId, enableSwipe: .constant(false)))
//                }
//            }
//        }
//        .task {
//            self.searchViewModel.jobSearch(parameter: searchRequest)
//        }
//        .onAppear {
//            isLoading = true
//            observe()
//        }
//    }
//    
//    //MARK: - View Modal Observer
//    func observe() {
//        self.searchViewModel.eventHandler = { event in
//            switch event {
//            case .loading:
//                self.isLoading = true
//            case .stopLoading:
//                self.isLoading = false
//            case .dataLoaded:
//                success()
//            case .error(let error):
//                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                showError = true
//            }
//        }
//    }
//    
//    //MARK: - Handle View Modal Success
//    func success() {
//        if searchViewModel.requestType == "JobSearch" {
//            if let response = searchViewModel.jobSearchResponse {
//                if response.status == "success" {
//                    totalPage = response.totalPage ?? 1
//                    if searchRequest.page == 1 {
//                        jobList.removeAll()
//                    }
//                                        
//                    response.data.forEach { data in
//                        if !jobList.contains(where: { $0.id == data.id }) {
//                            jobList.append(data)
//                        } else if let index = jobList.firstIndex(where: { $0.id == data.id }) {
//                            jobList[index] = data
//                        }
//                    }
//                    jobList.sort(by: { $0.created_at ?? "" > $1.created_at ?? "" })
//                    self.searchViewModel.getCompanyName()
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.snappy) { showError = true }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Search Execution with API Call
//    private func executeSearch(for query: String) {
//        guard !query.isEmpty else { return }
//        
//        searchRequest.search = query
//        searchRequest.page = 1
//        self.searchViewModel.jobSearch(parameter: searchRequest)
//    }
//    
//    //MARK: Handle Search Screen Pagination
//    func handlePagination(currentData item: JobDetailResponse) {
//        let thresholdData = jobList.last?.id
//        if thresholdData == item.id, (searchRequest.page + 1) <= totalPage {
//            searchRequest.page += 1
//            Task {
//                self.searchViewModel.jobSearch(parameter: searchRequest)
//            }
//        }
//    }
//}
//
//#Preview {
//    UserSearchScreen()
//}
