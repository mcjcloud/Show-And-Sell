//
//  StaggeredLayout.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/14/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

// MARK: Delegate protocol
protocol StaggeredLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath, with width: CGFloat) -> CGFloat
}

class StaggeredLayout: UICollectionViewLayout {
    // delegate for layout
    var delegate: StaggeredLayoutDelegate!
    
    // properties
    var numberOfColumns = 2
    var cellPadding: CGFloat = 3.0
    
    // layout attributes
    var cache = [UICollectionViewLayoutAttributes]()
    
    // size
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)  // return the width of the view minus the insets
    }
    
    // override content size variable
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // MARK: Layout functions
    override func prepare() {
        // if there are no attribtes
        if cache.isEmpty {
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            // build the offset array from the left axis per cell
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            // create the y offsets
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                
                let width = columnWidth - (cellPadding * 2)
                let cellHeight = delegate.collectionView(collectionView!, heightForCellAt: indexPath, with: width)
                let height = cellHeight + cellPadding
                
                // create the Cell frame
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // get attributes
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] += height
                
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }
    
    // override functions that gets the layout for elements in a given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // loop through the attributes in cache
        for attributes in cache {
            // if the attributes in cache is being displayed
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)     // add the attributes from cache to the resultant array
            }
        }
        
        // return the attributes
        return layoutAttributes
    }
    
}
