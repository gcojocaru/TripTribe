// MARK: - Header Component
import SwiftUI

struct NewTripHeaderView: View {
    let onBackTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackTap) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("New Trip")
                .font(.jakartaSans(18, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}
