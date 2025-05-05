//
//  EditListing Screen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI

struct EditListing_Screen: View {
    var body: some View {
        VStack(){
            PrimaryHeader(title: "Edit Listing",trailingImgArr: [.cancel], count: .constant(0))
            
            VStack(){
                TitleWithLine(title: "Edit Listing", lineLength: 24)
                    .padding([.top, .horizontal])
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15){
                        
                        AuthTextField(floatingLabel: "Job Title", placeholder: "Enter Job Title", icon: .bag, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Salary Type", placeholder: "Enter Salary Type", icon: .dollar, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Salary", placeholder: "Enter Salary", icon: .dollar, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Hours / Schedule", placeholder: "Enter Hours", icon: .hours, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Job Type", placeholder: "Enter Job Type", icon: .bag, text: .constant(""))
                        
//                        MultilineTextField(floatingLabel: "Job Description", placeholder: "Type your message here...")
                        
                        AuthTextField(floatingLabel: "Benefits", placeholder: "Enter Job Benefits", icon: .benefits, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Relevant Experience Required", placeholder: "Enter Experience", icon: .experience, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Licensure Required", placeholder: "Enter Licensure", icon: .licensure, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Educational Level Required", placeholder: "Enter Educational Level", icon: .gradCap, text: .constant(""))
                        
                        AuthTextField(floatingLabel: "Field of Education Required", placeholder: "Enter Field of Education", icon: .gradCap, text: .constant(""))
                        
                        PrimaryButton(title: "Next")
                            .padding(.top, 10)
                    }.padding([.leading,.trailing])
                }
                
            }.padding(.top, -topPadding)
        }
    }
}
#Preview {
    EditListing_Screen()
}
