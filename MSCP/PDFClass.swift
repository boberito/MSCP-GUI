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
//            let call = myText[indexPath.row]
        

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
