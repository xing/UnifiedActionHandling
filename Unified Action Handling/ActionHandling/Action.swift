import UIKit

public struct Action: ExpressibleByDictionaryLiteral {
    public typealias Key = XNGActionKey

    private(set) public var values: [String: Any]
    public init(dictionaryLiteral elements: (Key, Any)...) {
        var values: [String: Any] = [:]
        for (key, value) in elements {
            values[key.rawValue] = value
        }
        self.values = values
    }
    public init(_ values: [String: Any]) {
        self.values = values
    }
    fileprivate init(_ elements: [Key: Any]) {
        var values: [String: Any] = [:]
        for (key, value) in elements {
            values[key.rawValue] = value
        }
        self.values = values
    }

    public subscript(key: Key) -> Any? {
        get {
            return values[key.rawValue]
        }
        set {
            values[key.rawValue] = newValue
        }
    }

    public var type: String? {
        return self[.type] as? String
    }

    public var sourceView: UIView? {
        return self[.sourceView] as? UIView
    }

    public var sourceRect: CGRect? {
        return self[.sourceRect] as? CGRect
    }

    public var barButtonItem: UIBarButtonItem? {
        return self[.barButtonItem] as? UIBarButtonItem
    }

    public var viewControllerProperty: ViewControllerProperty? {
        return self[.viewControllerProperty] as? ViewControllerProperty
    }

    public var entityID: String? {
        return self[.entityID] as? String
    }

    public var title: String? {
        return self[.title] as? String
    }

    public var URL: URL? {
        return self[.URL] as? URL
    }

    public var tracking: String? {
        return self[.tracking] as? String
    }
}

extension Action.Key: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

fileprivate var actionHandlersKey = "actionHandlers"

// This container class is needed as there is a memory leak in _SwiftValue
// when we store the actionHandlers directly as associated object.
fileprivate class ActionHandlersContainer: NSObject {
    fileprivate var actionHandlers: [String: (Action) -> Void] = [:]
}

public extension UIResponder {
    @nonobjc public var actionHandlers: [String: (Action) -> Void] {
        get {
            return actionHandlersContainer.actionHandlers
        }
        set(newValue) {
            actionHandlersContainer.actionHandlers = newValue
        }
    }

    private var actionHandlersContainer: ActionHandlersContainer {
        if let result = objc_getAssociatedObject(self, &actionHandlersKey) as? ActionHandlersContainer {
            return result
        }
        let result = ActionHandlersContainer()
        objc_setAssociatedObject(self, &actionHandlersKey, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return result
    }
}

public extension UIView {
    @objc(xng_dispatchAction:)
    public func objcDispatch(action: [String: Any]?) {
        dispatch(action: action.map { .init($0) })
    }
    public func dispatch(action: Action?) {
        guard let action = action else {
            return
        }
        dispatch(action: action, sourceView: self, sourceRect: bounds)
    }
}

public extension UIResponder {
    /// From Swift, you can use actionHandlers[type] = handler instead
    @objc(xng_setActionHandler:forType:)
    public func set(handler: @escaping ([String: Any]) -> Void, forType type: String) {
        actionHandlers[type] = { handler($0.values) }
    }

    @objc(xng_dispatchAction:sourceView:sourceRect:)
    public func objcDispatch(action: [String: Any]?, sourceView: UIView, sourceRect: CGRect) {
        dispatch(action: action.map { .init($0) }, sourceView: sourceView, sourceRect: sourceRect)
    }

    public func dispatch(action: Action?, sourceView: UIView, sourceRect: CGRect) {
        guard var action = action else {
            return
        }
        action[.sourceView] = sourceView
        action[.sourceRect] = NSValue(cgRect: sourceRect)
        sourceView.dispatchInternal(action: action)
    }
}

public extension UIBarButtonItem {
    @objc(xng_dispatchAction:forEvent:)
    public func objcDispatch(action: [String: Any]?, for event: UIEvent) {
        dispatch(action: action.map { .init($0) }, for: event)
    }

    public func dispatch(action: Action?, for event: UIEvent) {
        guard var action = action else {
            return
        }
        action[.barButtonItem] = self
        event.allTouches?.first?.view?.dispatchInternal(action: action)
    }
}

fileprivate let selectorMatcher = try? NSRegularExpression(pattern: "\\A[a-zA-Z]\\w*\\:\\z", options: [])

fileprivate extension UIResponder {
    fileprivate func dispatchInternal(action: Action) {
        let type = action.type
        let selector = selectorFromAction(action)
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let type = type, let handler = responder.actionHandlers[type] {
                handler(action)
                return
            } else if let selector = selector, responder.responds(to: selector) {
                responder.perform(selector, with: action.values)
                return
            }
            nextResponder = responder.next
        }
    }

    private func selectorFromAction(_ action: Action) -> Selector? {
        let selectorString: String
        switch action[.selector] {
        case let selector as String:
            selectorString = selector
        case let selector as Selector:
            selectorString = NSStringFromSelector(selector)
        default:
            return nil
        }

        let range = NSRange(location: 0, length: selectorString.utf16.count)
        guard selectorMatcher?.firstMatch(in: selectorString, range: range) != nil else {
            return nil
        }

        return Selector(selectorString)
    }
}
