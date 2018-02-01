public extension CellSelectable {
    public var selectionAction: Action? {
        return __selectionAction.map { Action($0) }
    }
}

public extension MutableCellSelectable {
    public var selectionAction: Action? {
        get {
            return __selectionAction.map { Action($0) }
        }
        set {
            __selectionAction = newValue?.values
        }
    }
}
