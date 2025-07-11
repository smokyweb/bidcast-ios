//
//  ToolGridAnalyticsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUICore
import SwiftUI

struct ToolGridAnalyticsView: View {
    let title: String
      let chartData: [Double]
      let chartType: ChartType

       var body: some View {
           VStack(alignment: .leading, spacing: 8) {
                       Text(title)
                   .font(.custom(poppinsSemiBold, size: 13.0))

                       RoundedRectangle(cornerRadius: 8)
                           .fill(Color(.systemGray6))
                           .frame(height: 120)
                           .overlay(
                               Group {
                                   if chartType == .bar {
                                       TemporaryBarChartView(data: chartData)
                                   } else {
                                       TemporaryLineGraphView(data: chartData)
                                   }
                               }
                               .padding(.horizontal)
                           )
                   }
                   .padding(.horizontal)
       }
}



enum ChartType {
    case bar
    case line
}

struct TemporaryBarChartView: View {
    let data: [Double] // Values between 0 and 1

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data.indices, id: \.self) { index in
                Capsule()
                    .fill(.defaultTheme)
                    .frame(width: 12, height: CGFloat(data[index]) * 100)
            }
        }
        .frame(height: 100)
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
