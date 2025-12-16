//
//  ToolGridAnalyticsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

enum ChartType {
    case bar
    case line
}

struct ToolGridAnalyticsView: View {
    let title: String
    let chartData: [ChartData]
    let chartType: ChartType
    
    @State private var noDataMessage: String = ""
    @State private var selectedFilter: String = "All"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dropdown Filter
            HStack {
                Menu {
                    Button("All") { selectedFilter = "All" }
                    Button("Today") { selectedFilter = "Today" }
                    Button("This Week") { selectedFilter = "This Week" }
                    Button("This Month") { selectedFilter = "This Month" }
                } label: {
                    HStack(spacing: 8) {
                        Text(selectedFilter)
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
                
            // Chart Container
            ZStack {
                Color(.systemGray6)
                
                if chartData.isEmpty {
                    NoDataaView(message: noDataMessage)
                        .padding(.top, 40)
                } else {
                    if chartType == .bar {
                        CustomBarChartView(data: chartData)
                            .padding(.horizontal, 16)
                            .padding(.top, 30)
                            .padding(.bottom, 20)
                    } else {
                        CustomAreaChartView(data: chartData)
                            .padding(.horizontal, 16)
                            .padding(.top, 30)
                            .padding(.bottom, 20)
                    }
                }
            }
            .frame(height: 260)
            
            // Legend and Footer
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    LegendItem(color: .defaultTheme, label: "Livestream")
                    LegendItem(color: Color(red: 0.4, green: 0.6, blue: 0.3), label: "Marketplace")
                }
                .padding(.top, 12)
                
                Text("Time Zone: PST  May take 1-2 days for data to update")
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
        .cornerRadius(0)
        .onAppear {
            noDataMessage = chartType == .bar ? "No Sales Data Available" : "No Visitors Data Available"
        }
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.custom(poppinsSemiBold, size: 14.0))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - No Data View
struct NoDataaView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Chart Icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.clear)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            Text(message)
                .font(.custom(poppinsSemiBold, size: 12.0))
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Custom Bar Chart View
struct CustomBarChartView: View {
    let data: [ChartData]
    
    private var maxValue: Int {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            let chartHeight = geometry.size.height
            let barWidth: CGFloat = 40
            let totalBars = CGFloat(data.count)
            let totalSpacing = geometry.size.width - (totalBars * barWidth)
            let spacing = totalSpacing / (totalBars + 1)
            
            ZStack(alignment: .bottom) {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        if index < 4 {
                            Spacer()
                        }
                    }
                }
                
                // Bars
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(data) { item in
                        VStack(spacing: 0) {
                            Spacer()
                            if item.value > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue)
                                    .frame(width: barWidth, height: calculateBarHeight(value: item.value, maxHeight: chartHeight * 0.75))
                            } else {
                                Spacer()
                                    .frame(height: 0)
                            }
                        }
                    }
                }
                .padding(.horizontal, spacing)
            }
        }
    }
    
    private func calculateBarHeight(value: Int, maxHeight: CGFloat) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        let percentage = Double(value) / Double(maxValue)
        return CGFloat(percentage) * maxHeight
    }
}

// MARK: - Custom Area Chart View
struct CustomAreaChartView: View {
    let data: [ChartData]
    
    private var maxValue: Int {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        if index < 4 {
                            Spacer()
                        }
                    }
                }
                
                // Area fill
                areaPath(in: geometry.size)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Line
                linePath(in: geometry.size)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .position(pointPosition(for: index, in: geometry.size))
                }
            }
        }
    }
    
    private func linePath(in size: CGSize) -> Path {
        var path = Path()
        guard !data.isEmpty else { return path }
        
        let stepX = size.width / CGFloat(data.count - 1)
        
        for (index, item) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = size.height - (CGFloat(item.value) / CGFloat(maxValue) * size.height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    private func areaPath(in size: CGSize) -> Path {
        var path = linePath(in: size)
        
        guard !data.isEmpty else { return path }
        
        let stepX = size.width / CGFloat(data.count - 1)
        let lastX = CGFloat(data.count - 1) * stepX
        
        path.addLine(to: CGPoint(x: lastX, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        
        return path
    }
    
    private func pointPosition(for index: Int, in size: CGSize) -> CGPoint {
        let stepX = size.width / CGFloat(data.count - 1)
        let x = CGFloat(index) * stepX
        let y = size.height - (CGFloat(data[index].value) / CGFloat(maxValue) * size.height)
        return CGPoint(x: x, y: y)
    }
}
