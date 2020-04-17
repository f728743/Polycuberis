//
//  Misc.swift
//  Cuberis
//

import UIKit

func safeAreaInsets() -> UIEdgeInsets {
    UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets()
}
