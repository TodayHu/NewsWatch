//
//  Item.swift
//  watchtest
//
//  Created by Ukai Yu on 3/29/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import Realm

class Item : RLMObject{
    dynamic var id = ""
    dynamic var title = ""
    dynamic var publisherName = ""
    dynamic var content: String? = ""
    dynamic var isUnread = true
    dynamic var publishedAt = 0
}