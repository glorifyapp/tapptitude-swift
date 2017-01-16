//
//  TextCell.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 23/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

class TextCell : UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if #available(iOS 9.0, *) {
            return preferredLayoutAttributesFitting_VerticalResizing(layoutAttributes)
        } else {
            // Fallback on earlier versions
            return layoutAttributes
        }
    }
    
}

extension UICollectionViewCell {
    
    @available(iOS 9.0, *)
    open func preferredLayoutAttributesFitting_VerticalResizing(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        fixAutolayoutConstraintsForVerticalResizing()
        
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame = CGRect(origin: layoutAttributes.frame.origin, size: CGSize(width:layoutAttributes.frame.width, height:attributes.frame.height))
        return attributes
    }
    
    fileprivate func fixAutolayoutConstraintsForVerticalResizing() {
        let isDifferentSize = contentView.bounds.size != bounds.size
        let hasConstraints = !contentView.constraints.isEmpty
        if isDifferentSize && hasConstraints {
            contentView.bounds = self.bounds
            layoutIfNeeded()
            updateLabelsPreferredMaxWidhtBaseOnFrame()
        }
    }
}

fileprivate extension UIView {
    func updateLabelsPreferredMaxWidhtBaseOnFrame() {
        subviews.flatMap{$0 as? UILabel}.filter{$0.preferredMaxLayoutWidth == 0}.forEach{$0.preferredMaxLayoutWidth = $0.bounds.width}
        subviews.forEach{$0.updateLabelsPreferredMaxWidhtBaseOnFrame()}
    }
}
