extension Action.Key {
    static let color = Action.Key("color")
}

extension Action {
    var color: UIColor? { return self[.color] as? UIColor }
}
