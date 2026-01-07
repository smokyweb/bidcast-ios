//
//  LiveShowView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI
import AlertToast

// MARK: - LiveAuctionView
struct LiveAuctionView: View {
   // MARK: - Data States
    @Binding var liveShowsData: [HomeModel]
    @Binding var isLoadingAPI:Bool
    @Binding var currentPage: Int
    
    @State private var scrollOffset: CGFloat = 0
    
    var onTapProfile: ((Int) -> Void)?
    var onTapProfileName: ((Int) -> Void)?
    var onTapMainImage: ((Int) -> Void)?
    var onTapCategory: ((Int) -> Void)?
    
    let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                if isLoadingAPI && currentPage == 1 {
                    // 1️⃣ SHIMMER LOADING (First page only)
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(0..<6, id: \.self) { _ in
                            LiveAuctionShimmerView()
                        }
                    }
//                    .padding(.horizontal, 12)
                    
                } else if !isLoadingAPI && liveShowsData.isEmpty {
                    // 2️⃣ NO DATA VIEW
                    NoDataView1(message: "No live shows found")
                    .padding(.top, 40)
                    
                } else {
                    // 3️⃣ LIVE SHOWS GRID
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(liveShowsData.indices, id: \.self) { index in
                            LiveAuctionCardView(
                                auction: liveShowsData[index],
                                onTapProfile: {
                                    onTapProfile?(index)
                                },
                                onTapProfileName: {
                                    onTapProfileName?(index)
                                },
                                onTapMainImage: {
                                    onTapMainImage?(index)
                                },
                                onTapCategory: {
                                    onTapCategory?(index)
                                }
                            )
                        }
                        // Reading the offset
                        OffsetReader()
                            .frame(height: 0)
                    }
//                    .padding(.horizontal, 12)
                    
                    // PAGINATION LOADER
                    if isLoadingAPI && currentPage > 1 {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                print("Scrolling Offset →", scrollOffset)
            }
        }
    }
}

// MARK: - Live Auction Card with Actions
struct LiveAuctionCardView: View {
    let auction: HomeModel
    
    // Action Callbacks
    var onTapProfile: (() -> Void)?
    var onTapProfileName: (() -> Void)?
    var onTapMainImage: (() -> Void)?
    var onTapCategory: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header with Profile (Tappable)
            HStack(spacing: 8) {
                AsyncImageWithPlaceholder(
                    url: auction.user?.profile_image ?? "",
                    width: 22,
                    height: 22,
                    cornerRadius: 11
                )
                .onTapGesture {
                    onTapProfile?()
                }
                
                Text( auction.user?.username?.capitalizingFirstLetter() ?? auction.user?.name?.capitalizingFirstLetter() ?? "Unknown")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .onTapGesture {
                        onTapProfileName?()
                    }
                
                Spacer()
            }
//            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            
            // MARK: Thumbnail with Live Badge (Tappable)
            ZStack(alignment: .topLeading) {
                AsyncImageWithPlaceholder(
                    url: auction.thumbnail?.first ?? "",
                    width: 170,
                    height: 260,
                    cornerRadius: 0
                )
                
                .contentShape(Rectangle()) // Makes entire area tappable
                .onTapGesture {
                    onTapMainImage?()
                }
                .padding(1)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                )
                
                // Live Badge
                HStack(spacing: 5) {
//                    Image(systemName: "dot.radiowaves.left.and.right")
//                        .foregroundColor(.white)
//                        .font(.system(size: 11, weight: .bold))
//                    
                    Text("Live • \(auction.latest_viewer_count ?? 0)")
                        .font(.custom(poppinsSemiBold, size: 12))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(10)
//                .allowsHitTesting(false) // Badge doesn't intercept taps
            }
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            
            // MARK: Bottom Info
            VStack(alignment: .leading, spacing: 0) {
                Text(auction.title?.capitalizingFirstLetter() ?? "Live Show")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.black)
                    .lineLimit(2)
//                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 4) {
                    Text(auction.category?.name?.capitalizingFirstLetter() ?? "General")
                        .font(.custom(poppinsSemiBold, size: 10))
                        .foregroundColor(.gray)
                        .onTapGesture {
                            onTapCategory?()
                        }
                    
                    Spacer()
                }
            }
//            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
        .background(Color.clear)
    }
}

// MARK: - Async Image with Placeholder
struct AsyncImageWithPlaceholder: View {
    let url: String
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                // Show placeholder while loading
                ZStack {
                    Color.gray.opacity(0.2)
                    
                    Image(systemName: "photo")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 30))
                }
                .frame(width: width, height: height)
                
            case .success(let image):
                // Show loaded image
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
                
            case .failure:
                // Show error placeholder
                ZStack {
                    Color.gray.opacity(0.2)
                    
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red.opacity(0.6))
                        .font(.system(size: 30))
                }
                .frame(width: width, height: height)
                
            @unknown default:
                EmptyView()
            }
        }
        .cornerRadius(cornerRadius)
    }
}

// MARK: - Shimmer View
struct LiveAuctionShimmerView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Profile shimmer
            HStack(spacing: 8) {
                PulseShimmerView()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                
                PulseShimmerView()
                    .frame(width: 80, height: 12)
                    .cornerRadius(6)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            
            // Image shimmer
            PulseShimmerView()
                .frame(height: 180)
            
            // Bottom info shimmer
            VStack(alignment: .leading, spacing: 6) {
                PulseShimmerView()
                    .frame(height: 12)
                    .cornerRadius(6)
                
                PulseShimmerView()
                    .frame(width: 100, height: 10)
                    .cornerRadius(5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Pulse Shimmer Effect
//struct PulseShimmerView: View {
//    @State private var isAnimating = false
//    
//    var body: some View {
//        LinearGradient(
//            colors: [
//                Color.gray.opacity(0.3),
//                Color.gray.opacity(0.15),
//                Color.gray.opacity(0.3)
//            ],
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//        .mask(
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        colors: [.clear, .black, .clear],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    )
//                )
//                .offset(x: isAnimating ? 400 : -400)
//        )
//        .onAppear {
//            withAnimation(
//                .linear(duration: 1.5)
//                .repeatForever(autoreverses: false)
//            ) {
//                isAnimating = true
//            }
//        }
//    }
//}

// MARK: - No Data View
struct NoDataView1: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct OffsetReader: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                   value: geo.frame(in: .named("scroll")).minY)
        }
    }
}
