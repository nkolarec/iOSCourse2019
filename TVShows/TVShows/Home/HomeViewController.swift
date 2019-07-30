//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 18/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

final class HomeViewController: UIViewController {
    
    //MARK: - Properties
    private var shows: [Show] = []
    var token: String = ""
    
    // MARK: - Private UI
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.black)
        _loadShows()
    }
}

// MARK: - UITableView
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let show = shows[indexPath.row]
        print("Selected show: \(show)")
        _showDetails(showId: show.id)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("CURRENT INDEX PATH BEING CONFIGURED: \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShowTableViewCell.self), for: indexPath) as! ShowTableViewCell
        cell.configure(show: shows[indexPath.row])
        return cell
    }
}

//MARK: - Authorize user and set up UI
private extension HomeViewController {
    
    private func setupTableView() {
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func _loadShows(){
        SVProgressHUD.show()
        let headers = ["Authorization": token]
        Alamofire
            .request(
                "https://api.infinum.academy/api/shows",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { [weak self] (response: DataResponse<[Show]>) in
                switch response.result {
                case .success(let shows):
                    print("Success: \(shows)")
                    guard let self = self else { return }
                    self.shows = shows
                    self.setupTableView()
                    self.tableView.reloadData()
                case .failure(let error):
                    print("API failure: \(error)")
                    SVProgressHUD.showError(withStatus: "Error")
                }
                SVProgressHUD.dismiss()
        }
    }
}

//MARK: - Navigate to show details of the TV show
private extension HomeViewController {
    
    private func _showDetails(showId: String){
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "ShowDetails", bundle: bundle)
        let showDetailsViewController = storyboard.instantiateViewController(
            withIdentifier: "ShowDetailsViewController"
            ) as! ShowDetailsViewController
        navigationController?.pushViewController(showDetailsViewController, animated: true)
        showDetailsViewController.token = self.token
        showDetailsViewController.showId = showId
    }
}
