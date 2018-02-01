class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        actionHandlers["showColor"] = { [weak self] action in
            guard let color = action.color else { return }

            self?.window?.rootViewController?.show(viewController(for: color), sender: self)
        }

        actionHandlers["previewColor"] = { action in
            guard let color = action.color,
                let viewControllerProperty = action.viewControllerProperty else { return }

            if viewControllerProperty.viewController == nil {
                viewControllerProperty.viewController = viewController(for: color)
            }
        }

        return true
    }
}

fileprivate func viewController(for color: UIColor) -> UIViewController {
    let controller = UIViewController()
    controller.view.backgroundColor = color
    return controller
}
