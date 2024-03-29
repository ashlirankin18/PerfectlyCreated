//
//  SearchProductViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/20/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import CombineCocoa
import Combine
import FirebaseAuth

/// `UIViewContrller` subclass which allows a user to search for a product.
final class SearchProductViewController: UIViewController {
    
    @IBOutlet private weak var dismissBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var productTableView: UITableView!
    
    private var allHairProducts = [AllHairProducts]() {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.title = "\(self.allHairProducts.count) Products"
                self.productTableView.reloadData()
            }
        }
    }
    
    private lazy var productManager = ProductManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.backgroundColor = .clear
        searchController.isAccessibilityElement = true
        searchController.searchBar.isAccessibilityElement = true
        searchController.searchBar.accessibilityLabel = NSLocalizedString("Search Bar", comment: "Indicates to the user that this object is a search bar")
        searchController.accessibilityLabel = NSLocalizedString("Search Controller", comment: "Indicates to the user that this object is a search controller")
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.nibName)
        configureNavigationItemProperties()
        setDelegates()
        configureDismissButtonHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.allHairProducts = ProductManager.getProducts().sorted { $0.results.name < $1.results.name }
    }
    
    // MARK: - SearchProductViewController
    
    private func setDelegates() {
        productTableView.dataSource = self
        productTableView.delegate = self
    }
   
    private func configureNavigationItemProperties() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func configureDismissButtonHandler() {
        dismissBarButtonItem.tapPublisher.sink {
            self.dismiss(animated: true)
        }
        .store(in: &cancellables)
    }
}

extension SearchProductViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allHairProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = productTableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.nibName, for: indexPath) as? SearchTableViewCell else {
            fatalError("no product display cell found")
        }
        let hairProduct = allHairProducts[indexPath.row]
        cell.productName.text = hairProduct.results.name.capitalized
        cell.categoryLabel.text = hairProduct.results.category
        cell.productImage.kf.setImage(with: hairProduct.results.images.first)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let model = self.allHairProducts[indexPath.row]
        let product = ProductModel(productName: model.results.name, documentId: productManager.documentId, productDescription: model.results.features?.blob ?? model.results.description, userId: currentUser.uid, productImageURL: model.results.images.first?.absoluteString ?? "", category: model.results.category, isCompleted: false, notes: nil, upc: model.results.upc, stores: [])
        
        let productController =
            UIStoryboard(name: ProductDetailViewController.nibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.nibName) { coder in
                return ProductDetailViewController(coder: coder, productType: .general, productModel: product)
        }
        
        self.navigationController?.pushViewController(productController, animated: true)
    }
}

extension SearchProductViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension SearchProductViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        if searchText.isEmpty {
            allHairProducts = ProductManager.getProducts()
        } else {
            let anArray = allHairProducts.filter({ $0.results.name.contains(searchText.capitalized) })
            allHairProducts = anArray.sorted { $0.results.name < $1.results.name }
            self.navigationItem.title = "\(allHairProducts.count) Products"
        }
    }
}
