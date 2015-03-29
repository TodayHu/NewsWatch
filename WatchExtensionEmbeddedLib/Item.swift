//
//  Item.swift
//  watchtest
//
//  Created by Ukai Yu on 3/29/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import Realm

public class Item : RLMObject{
    public dynamic var id = ""
    public dynamic var title = ""
    public dynamic var publisherName = ""
    public dynamic var content: String? = ""
    public dynamic var isUnread = true
    public dynamic var publishedAt = 0
}