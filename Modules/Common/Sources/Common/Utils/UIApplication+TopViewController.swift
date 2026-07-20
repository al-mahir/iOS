//
//  UIApplication+TopViewController.swift
//  Common
//
//  Created by Nadin Ahmed on 20/07/2026.
//
import UIKit

public extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseViewController = base ?? connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        if let nav = baseViewController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseViewController as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = baseViewController?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseViewController
    }
}
