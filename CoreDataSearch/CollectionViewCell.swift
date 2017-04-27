//
//  CollectionViewCell.swift
//  CoreDataSearch
//
//  Created by Vamshi Krishna on 27/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

protocol TapCellDelegate:NSObjectProtocol{
    func buttonTapped(indexPath:IndexPath)
}

class CollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var topButton: UIButton!
    weak var delegate:TapCellDelegate?
    @IBOutlet weak var itemIdLabel: UILabel!
    
    public var indexPath:IndexPath!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if let delegate = self.delegate{
            delegate.buttonTapped(indexPath: indexPath)
        }
    }
}
