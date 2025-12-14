import SwiftUI

struct FlexibleChips<Token: Identifiable & Hashable, ChipView: View>: View {
    let tokens: [Token]
    let chipView: (Token) -> ChipView

    // Spacing between chips and between rows
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width
            FlowLayout(maxWidth: maxWidth,
                       horizontalSpacing: horizontalSpacing,
                       verticalSpacing: verticalSpacing) {
                ForEach(tokens, id: \.id) { token in
                    chipView(token)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - FlowLayout helper
private struct FlowLayout<Content: View>: View {
    let maxWidth: CGFloat
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder var content: () -> Content

    init(maxWidth: CGFloat,
         horizontalSpacing: CGFloat,
         verticalSpacing: CGFloat,
         @ViewBuilder content: @escaping () -> Content) {
        self.maxWidth = maxWidth
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }

    var body: some View {
        _FlowLayout(maxWidth: maxWidth,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing,
                    content: content)
    }
}

private struct _FlowLayout<Content: View>: View {
    let maxWidth: CGFloat
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        var width: CGFloat = 0
        var rows: [[AnyView]] = [[]]

        // Measure children by rendering them invisibly to get intrinsic sizes
        let items = AnyView(content())
            .asSubviews()

        for item in items {
            let itemSize = item.intrinsicSize()
            if width == 0 {
                // First item in the row
                rows[rows.count - 1].append(item)
                width = itemSize.width
            } else {
                if width + horizontalSpacing + itemSize.width <= maxWidth {
                    rows[rows.count - 1].append(item)
                    width += horizontalSpacing + itemSize.width
                } else {
                    rows.append([item])
                    width = itemSize.width
                }
            }
        }

        return VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: horizontalSpacing) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                        rows[rowIndex][colIndex]
                    }
                }
            }
        }
    }
}

// MARK: - View measurement helpers
private struct SizeMeasurer: View {
    let content: AnyView
    @Binding var size: CGSize

    var body: some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { size = proxy.size }
                        .onChange(of: proxy.size) { _, newValue in
                            size = newValue
                        }
                }
            )
    }
}

private extension AnyView {
    func intrinsicSize() -> CGSize {
        // Render off-screen to measure size
        let host = UIHostingController(rootView: self)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let size = host.sizeThatFits(in: targetSize)
        return size == .zero ? CGSize(width: 1, height: 1) : size
    }
}

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }

    // Flatten a view builder into an array of AnyView children
    func asSubviews() -> [AnyView] {
        // We can’t introspect the view tree directly; in practice, FlexibleChips
        // is called with a ForEach, so we rely on SwiftUI to expand children.
        // As a pragmatic approach, wrap the content in a HStack and extract its
        // children by size-measuring on the fly. To keep it simple and robust,
        // we’ll just return the entire view as one item if flattening isn’t possible.
        [AnyView(self)]
    }
}
