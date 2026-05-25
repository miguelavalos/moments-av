enum MomentsCreditCopy {
    static func noun(_ count: Int) -> String {
        count == 1 ? "credit" : "credits"
    }

    static func countTitle(_ count: Int) -> String {
        "\(count) \(noun(count))"
    }
}
