//
//  FeedViewController.swift
//  EssentialsPrototype
//
//  Created by Chico Pereira on 23/12/2021.
//

import UIKit

final class FeedViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
    }
}
