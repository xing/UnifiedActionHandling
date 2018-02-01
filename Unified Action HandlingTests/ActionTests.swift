import XCTest

public class HelperView: UIView {
    var lastAction: Action?
    @objc(foo:) public func foo(_ action: [String: Any]) {
        lastAction = Action(action)
    }
}

extension Action.Key {
    static let entityId = Action.Key("entityId")
}

class ActionTests: XCTestCase {

    let subview = HelperView()
    let superview = HelperView()

    override func setUp() {
        super.setUp()
        superview.addSubview(subview)
    }

    func testActionWithTypeIsHandled() {
        var actionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            actionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test123"])
        XCTAssert(actionHandlerWasCalled)
    }

    func testActionWithSelectorStringIsHandled() {
        subview.dispatch(action: [.selector: NSStringFromSelector(#selector(HelperView.foo))])
        XCTAssert(subview.lastAction != nil)
    }

    func testActionWithSelectorIsHandled() {
        subview.dispatch(action: [.selector: #selector(HelperView.foo)])
        XCTAssert(subview.lastAction != nil)
    }

    func testActionIsPassedUpResponderChain() {
        var actionHandlerWasCalled = false
        superview.actionHandlers["test123"] = { _ in
            actionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test123"])
        XCTAssert(actionHandlerWasCalled)
    }

    func testUnhandledActionIsIgnored() {
        var actionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            actionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test246"]) // Note the different type
        XCTAssert(!actionHandlerWasCalled)
    }

    func testOneActionHandlerPerType() {
        var firstActionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            firstActionHandlerWasCalled = true
        }
        var secondActionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            secondActionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test123"])
        XCTAssert(secondActionHandlerWasCalled)
        XCTAssert(!firstActionHandlerWasCalled)
    }

    func testResetActionHandler() {
        var actionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            actionHandlerWasCalled = true
        }
        subview.actionHandlers["test123"] = nil
        subview.dispatch(action: [.type: "test123"])
        XCTAssert(!actionHandlerWasCalled)
    }

    // Corner case: The type is for shiny swift code, so it should take precedence
    func testActionTypeTakesPrecedence() {
        var actionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            actionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test123", .selector: #selector(HelperView.foo)])
        XCTAssert(actionHandlerWasCalled)
        XCTAssert(subview.lastAction == nil)
    }

    func testActionHandlingDoesNotBubbleUp() {
        var superviewActionHandlerWasCalled = false
        superview.actionHandlers["test123"] = { _ in
            superviewActionHandlerWasCalled = true
        }
        var subviewActionHandlerWasCalled = false
        subview.actionHandlers["test123"] = { _ in
            subviewActionHandlerWasCalled = true
        }
        subview.dispatch(action: [.type: "test123"])
        XCTAssert(subviewActionHandlerWasCalled)
        XCTAssert(!superviewActionHandlerWasCalled)
    }

    func testActionDispatchAddsSourceViewAndSourceRect() {
        subview.frame = CGRect(x: 42, y: 48, width: 200, height: 100)
        var action: Action?
        subview.actionHandlers["test123"] = {
            action = $0
        }
        subview.dispatch(action: [.type: "test123", .entityId: "1234_adsf"])

        XCTAssertEqual(action?[.type] as? String, "test123")
        XCTAssertEqual(action?[.entityId] as? String, "1234_adsf")
        XCTAssertEqual(action?.sourceView, subview)
        XCTAssertEqual(action?.sourceRect, subview.bounds)
    }
}
