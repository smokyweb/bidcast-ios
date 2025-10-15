//
//  ToolGridAnalyticsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct ToolGridAnalyticsView: View {
    let title: String
    let chartData: [ChartData]
    let chartType: ChartType
    
    @State var noDataMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 13.0))
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(height: 180)
                .overlay(
                    Group {
//                        if chartData.isEmpty {
//                            NoDataView(message: noDataMessage)
//                        } else {
                            if chartType == .bar {
                                BarChartView(data: chartData)
                                
                            } else {
                                AreaChartView(data: chartData)
                            }
//                        }
                    }
                        .padding(.horizontal)
                )
        }
        
        .onAppear {
            if chartType == .bar {
                noDataMessage = "No Sales Found."
            }
            else  {
                noDataMessage = "Visitors Data Not Found"
            }
        }
        .padding(.horizontal)
    }
}



enum ChartType {
    case bar
    case line
}

struct TemporaryBarChartView: View {
    let data: [Double]
    @State var barRatio:Int = 100
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data.indices, id: \.self) { index in
                Capsule()
                    .fill(.defaultTheme)
                    .frame(width: 12, height: CGFloat(data[index]) * CGFloat(barRatio))
            }
        }
        .frame(height: 100)
        .onAppear {
            barRatio = getBarRatio(with: data)
        }
    }
    
    func getBarRatio(with data: [Double]) -> Int {
        var barRatio = 100
        let max = findMaxValue(with: data)
        
        if max <= 0.0 {
            barRatio = 100
        }
        else if max > 0.0 && max < 100.0 {
            barRatio = 10
        }
        else {
            barRatio = 1
        }
        return barRatio
    }
    
    // Helper function to find the maximum value in the data array
    func findMaxValue(with data: [Double]) -> Double {
        if let max = data.max() {
            return max
        }
        return 0.0
    }
    
}


struct TemporaryLineGraphView: View {
    let data: [Double] // Values between 0 and 1
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let step = width / CGFloat(data.count - 1)
            
            Path { path in
                guard let firstPoint = data.first else { return }
                path.move(to: CGPoint(x: 0, y: height * (1 - firstPoint)))
                
                for index in 1..<data.count {
                    let x = CGFloat(index) * step
                    let y = height * (1 - data[index])
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.defaultTheme, lineWidth: 2)
        }
        .frame(height: 100)
    }
}
