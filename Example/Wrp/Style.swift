import SwiftUI

struct WrpButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .foregroundColor(.white)
            .padding()
            .background((configuration.isPressed ? self.color.opacity(0.9) : self.color).cornerRadius(4))
    }
}
