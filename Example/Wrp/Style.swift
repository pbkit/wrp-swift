import SwiftUI

struct WrpButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .foregroundColor(.white)
            .padding()
            .background((configuration.isPressed ? color.opacity(0.9) : color).cornerRadius(4))
    }
}
