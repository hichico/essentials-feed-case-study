//
//  UIRefreshControl+Helpers.swift
//  EssentialsFeediOS
//
//  Created by Chico Pereira on 22/01/2022.
//

import UIKit

 extension UIRefreshControl {
     func update(isRefreshing: Bool) {
         isRefreshing ? beginRefreshing() : endRefreshing()
     }
 }
