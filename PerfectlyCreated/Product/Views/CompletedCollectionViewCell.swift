//
//  CompletedCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/2/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// `UICollectionViewCell` subclass which displays the if a product is completed.
final class CompletedCollectionViewCell: UICollectionViewCell {
    
    /// Contains the information needed to cofigure `CompletedCollectionViewCell`.
    struct ViewModel {
        
        /// Represents the various configurations the cell can have.
        enum Configuration {
            
            /// Represents if the cells is not editing.
            case display
            
            /// Represents if the cells is editing.
            case editing
        }
        
        /// Represents if the product is complete.
        let isCompleted: Bool
        
        /// The title of the cell.
        let title: String
        
        /// The configurations the cell can take.
        let configuration: Configuration
        
        fileprivate var completeImage: UIImage {
            if isCompleted {
                return UIImage(systemName: "checkmark.circle.fill") ?? UIImage()
            } else {
                return UIImage(systemName: "checkmark.circle") ?? UIImage()
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkmarkButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isCompletedPassThroughSubject = PassthroughSubject<Bool, Never>()
    
    /// Called when changes to the product completion state are published.
    var isCompletePublisher: AnyPublisher<Bool, Never> {
        return isCompletedPassThroughSubject.eraseToAnyPublisher()
    }
    
    /// Single point of configuration of `CompletedCollectionViewCell`.
    var viewModel: ViewModel? {
        didSet {
            
            guard let viewModel = viewModel else {
                return
            }
            titleLabel.text = viewModel.title
            checkmarkButton.isSelected = viewModel.isCompleted
            checkmarkButton.setImage(viewModel.completeImage, for: .selected)
           
            checkmarkButton.isUserInteractionEnabled = viewModel.configuration == .editing
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkButton.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            self.checkmarkButton.isSelected.toggle()
            
            if self.checkmarkButton.isSelected {
                self.checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            } else {
                self.checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
            }
            self.isCompletedPassThroughSubject.send(self.checkmarkButton.isSelected)
        }
        .store(in: &cancellables)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    
    private func configureCell() {
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 25
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.appPurple.withAlphaComponent(0.3).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
