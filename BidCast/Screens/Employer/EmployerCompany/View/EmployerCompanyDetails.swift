//
//  EmployerCompanyDetails.swift
//  imperium
//
//  Created by JAM-E-265 on 09/02/24.
//


import SwiftUI

struct EmployerCompanyDetails: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                HeaderWithImageTitle(
                    title: "Employer Company",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    userName: .constant("Company Logo"),
                    userImg: .constant(""))
                Spacer()
                VStack(alignment: .leading) {
                    
                    TitleWithLine(title: "Company Details", lineLength: 36)
                        .padding([.top, .horizontal])
                    
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 16, content: {
                            
                            AuthTextField(floatingLabel: "Company Name", placeholder: "Enter Company Name", icon: .bag, text: .constant("")) { email in
                                print("User Email >> \(email)")
                                //                                self.request.email = email
                            }
                            
                            AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .bag, text: .constant("")) { email in
                                print("User Email >> \(email)")
                                //                                self.request.email = email
                            }
                            
                            AuthTextField(floatingLabel: "Phone Number", placeholder: "Enter Phone Number", icon: .bag,  text: .constant("")) { password in
                                print("User Email >> \(password)")
                                //                                self.request.password = password
                            }
                            
                            AuthTextField(floatingLabel: "Password", placeholder: "Enter Password", icon: .bag,  text: .constant("")) { password in
                                print("User Email >> \(password)")
                                //                                self.request.password = password
                            }
                            
                            AuthTextField(floatingLabel: "Locaton", placeholder: "Enter Locaton", icon: .bag,  text: .constant("")) { password in
                                print("User Email >> \(password)")
                                //                                self.request.password = password
                            }
                           
                            
                            PrimaryButton(title: "Submit") {
                                
                                
                            }
                        }).padding([.horizontal, .vertical])
                    }
                    Spacer()
                }
                .background(.text.opacity(0.05))
                .padding(.top, -topPadding)
                
                Spacer()
            })
        }
        .edgesIgnoringSafeArea(.bottom)
    }

}


#Preview {
    EmployerCompanyDetails()
}

