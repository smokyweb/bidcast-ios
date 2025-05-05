//
//  JobListCardImg.swift
//  imperium
//
//  Created by JAM-E-282 on 22/01/24.
//

import SwiftUI
import Kingfisher

struct JobListCardImg: View {
    
    var jobData: JobDetailResponse = JobDetailResponse()
    
    var onSelected: ((Int) -> Void)?
    
    var body: some View {
        Button(action: { 
            if let id = jobData.id {
                self.onSelected?(id)
            } }, label: {
            HStack(alignment: .top, spacing: 10) {
                
                KFImage.url(getMediaURL(url: jobData.user?.company_data?.company_logo ?? "" != "" ? jobData.user?.company_data?.company_logo ?? "" : jobData.user?.profile_image ?? ""))
                    .placeholder({
                        Image(.imgPlaceholder)
                            .resizable()
                            .blur(radius: 1.5)
                    })
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0, content: {
                    
                    HStack(spacing: 0) {
                        Text(jobData.title ?? "Job Title")
                            .font(.custom(nunitoBold, fixedSize: 18))
                            .bold()
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(.sideArrow)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            .rotationEffect(Angle(degrees: 180))
                    }
                    
                    
                    Text(jobData.job_type ?? "")
                        .font(.custom(nunitoLight, fixedSize: 14))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.text)
                    
                    Text(jobData.updated_at?.stringISOToDate().offsetFrom() ?? "")
                        .font(.custom(nunitoLight, fixedSize: 12))
                        .foregroundStyle(.gray)
                })
            }
            .padding(.all)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            )
        })
    }
}

#Preview {
    JobListCardImg()
}
