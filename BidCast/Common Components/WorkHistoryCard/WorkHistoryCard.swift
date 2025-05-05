//
//  WorkHistoryCard.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import SwiftUI
import RichText

struct WorkHistoryCard: View {
    
    @Binding var workHistory: WorkHistory
    
    var onEditWorkClick: ((WorkHistory) -> Void)?
    var onRemoveClick: ((WorkHistory) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Job Title")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    HStack {
                        Text(workHistory.job_title ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 14))
                            .foregroundStyle(.black)
                        Circle()
                            .fill(.black)
                            .frame(width: 5)
                        Text(workHistory.employment_type ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 14))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Company")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        Circle()
                            .fill(.gray)
                            .frame(width: 5)
                        Text("Industry")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    HStack {
                        Text(workHistory.company_name ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 14))
                            .foregroundStyle(.black)
                        Circle()
                            .fill(.black)
                            .frame(width: 5)
                        Text(workHistory.industry ?? "")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Contact Info")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Text("\(workHistory.contact_info ?? "")")
                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                        .foregroundStyle(.black)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duration")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Text("\((workHistory.start_date ?? "").toDate().toMMYY()) - \((workHistory.end_date ?? ""))")
                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                        .foregroundStyle(.black)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Profile Headline")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Text(workHistory.profile_headline ?? "")
                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                        .foregroundStyle(.black)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Location")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Text(workHistory.location ?? "")
                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Description")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    RichText(html: workHistory.description?.htmlToString ?? " - ")
                        .customCSS("""
            body {
                font-size: 14px;
            }
        """)
                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
        .overlay(alignment: .topTrailing, content: {
            HStack {
                Button(action: { self.onEditWorkClick?(workHistory) }, label: {
                    Image(.circleEditPencil)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.text)
                })
                
                Button(action: { self.onRemoveClick?(workHistory) }, label: {
                    Image(systemName: "minus.circle.fill")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.red)
                })
            }
        })
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
}

#Preview {
    WorkHistoryCard(workHistory: .constant(WorkHistory(job_title: "", company_name: "", location: "", employment_type: "", location_type: "", start_date: "", end_date: "", profile_headline: "", description: "", industry: "", contact_info: "")))
}

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
