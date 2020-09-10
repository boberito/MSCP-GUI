//
//  PDFClass.swift
//  MSCP
//
//  Created by Bob Gendler on 9/2/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation
import PDFAuthor
import Cassowary

class MultiplePages: TableChapter, TableChapterDataSource {
    
    override init(pageSpecifications: PDFPageSpecifications) {
           super.init(pageSpecifications: pageSpecifications)
           self.outlineTitle = "Compliance Report"
           self.dataSource = self
       }
    var checkCount = Int()
    var contentText = [String]()
    func numberOfSections(in: TableChapter) -> UInt {
        return 1
    }
    
    func tableChapter(_ tableChapter: TableChapter, numberOfColumnsInSection: Int) -> Int {
        return 1
    }
    
    func tableChapter(_ tableChapter: TableChapter, numberOfRowsInSection: Int) -> Int {
        return checkCount
    }
    
    func tableChapter(_ tableChapter: TableChapter, backgroundColorForRowAtIndexPath indexPath: PDFIndexPath) -> PDFColor? {
        return indexPath.row % 2 == 0 ? .clear : PDFColor(white: 0.9, alpha: 1.0)
    }
    func tableChapter(_ tableChapter: TableChapter, insetsForRowAtIndexPath indexPath: PDFIndexPath) -> PDFEdgeInsets {
          return PDFEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
      }
    
    func tableChapter(_ tableChapter: TableChapter, regionFor indexPath: PDFIndexPath) -> PDFRegion {

        let entry = contentText[indexPath.row]
        
           switch indexPath.column {
           case 0:
               let region = StringRegion(string: entry)
               
               return region
           default:
               return PDFRegion(frame: .zero)
           }
      }
    
}

class TitleChapter: PDFChapter {
    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
    }
    
    var title = String()
    
    override func generate() {
        withNewPage {
            $0.backgroundColor = PDFColor(white: 0.95, alpha: 1.0)
            
            let titleRegion = StringRegion(string: title,
                                           font: PDFFont.boldSystemFont(ofSize: 24),
                                           color: PDFColor(white: 0.1, alpha: 1.0),
                                           alignment: .center)
            
            $0.addChild(titleRegion)
            
            titleRegion.addConstraints(
                titleRegion.left == $0.leftInset,
                titleRegion.right == $0.rightInset,
                titleRegion.centerY == $0.centerY
            )
        }
    }
}

class regularPage: PDFChapter {

    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
    }

    var content = String()
    override func generate() {
        withNewPage {
            $0.backgroundColor = PDFColor(white: 0.95, alpha: 1.0)

            let r = MultiColumnStringRegion(string: content,
                    font: .systemFont(ofSize: 10),
                    color: PDFColor(white: 0, alpha: 1.0),
                    alignment: .left,
                    numColumns: 1)

            r.preferredMaxLayoutWidth = $0.contentWidth

            $0.addChild(r)

            r.addConstraints(
                    r.left == $0.leftInset,
                    r.right == $0.rightInset,
                    r.top == $0.topInset)
        }
    }
}
