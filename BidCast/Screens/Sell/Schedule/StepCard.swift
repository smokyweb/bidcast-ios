struct StepCard: View {
    let prepare :  LessonModel
    let index: Int
    let isCurrent: Bool
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(prepare.isLocked ? Color(.systemGray4) : Color.blue)
                        .frame(width: 32, height: 32)
                    
                    if prepare.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                            .font(.footnote)
                    } else {
                        Text("\(index)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding(.leading,8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(prepare.title ?? "")
                        .font(.headline)
                        .foregroundColor(prepare.isLocked ? .gray : .primary)
                    RichText(html: prepare.description ?? "")
                    
                }
//                Spacer()
            }
            
            .padding(.all,12)
            if isCurrent && !prepare.isLocked {
                PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                    action()
                },cornerRadius: 12,btnTextColor: .white)
//                .padding(.horizontal,12)
            }
        }

        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .opacity(prepare.isLocked ? 0.6 : 1)
                )
                .padding(.horizontal,12)
        )
               
    }
    

  
}
