struct ToggleCell: View {
    var title : String = "About Us"
    var textColor : Color?
    var fontValue : CGFloat = 15
    @Binding var isTappedSwitch : Bool
    var onToggle: ((Bool) -> Void)? = nil
   
    
    var body: some View {
        
            HStack{
                
                Text(title)
                    .font(.custom(poppinsSemiBold, fixedSize: fontValue))
                    .bold()
                    .foregroundStyle(.text)
                    .foregroundColor(textColor)
                    .padding(.leading, 4)
                Spacer()
                
                
                Rectangle()
                    .fill(isTappedSwitch ? .tabBar : .bg)
                    .frame(width: 44,height: 28)
                    .cornerRadius(14)
                    .opacity(1)
                    .onTapGesture {
                        isTappedSwitch.toggle()
                        onToggle?(isTappedSwitch)
                    }
                
                
        }
        .frame(height: 30)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
       
    }
}
