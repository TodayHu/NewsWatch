//
//  SpeedReadingManager.swift
//  watchtest
//
//  Created by Ukai Yu on 4/5/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import Realm

public class SpeedReadingManager{
    
    public class func convertStringToArray(entryId:String, completion:((error:NSError?, result:Array<String>)->Void)?){
        var array:Array<String> = []
        var text:NSString = ""
        let realm = RLMRealm.defaultRealm()
        let predicate = NSPredicate(format: "id = %@", entryId)
        if let item = Item.objectsWithPredicate(predicate).firstObject() as! Item? {
            
            let lang = getLanguage(item.title)
            
            AlchemyManager.sharedInstance.getExtractedTextWithUrl(item.url, completion: { resultText in
                text = resultText
                let schemes = [NSLinguisticTagSchemeLexicalClass]
                let options = NSLinguisticTaggerOptions.OmitWhitespace | NSLinguisticTaggerOptions.JoinNames
                let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
                tagger.string = text as String
                let textRange = NSMakeRange(0, text.length-1)
  
                tagger.enumerateTagsInRange(textRange, scheme: NSLinguisticTagSchemeLexicalClass, options: options, usingBlock:{ (tag:String!, tokenRange:NSRange, _, _) -> Void in
                    let token = text.substringWithRange(tokenRange)
                    if( tag != NSLinguisticTagNoun && tag != NSLinguisticTagVerb && tag != NSLinguisticTagAdjective && tag != NSLinguisticTagAdverb && tag != NSLinguisticTagPronoun ){
                        array[array.count-1] = array.last as String! + token
                    }else{
                        array.append(token)
                    }
                })
                println(array)
                completion?(error: nil,result: array)
            })
        }
    }
    
    public class func getLanguage(text:NSString) -> String{
        let schemes = [NSLinguisticTagSchemeLanguage]
        let options = NSLinguisticTaggerOptions.OmitWhitespace | NSLinguisticTaggerOptions.OmitPunctuation | NSLinguisticTaggerOptions.OmitOther
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = text as String
        let textRange = NSMakeRange(0, (text.length-1 >= 10 ? 10 : text.length-1))
        var countDic = Dictionary<String, Int>()
        tagger.enumerateTagsInRange(textRange, scheme: NSLinguisticTagSchemeLanguage, options: options, usingBlock:{ (tag:String!, tokenRange:NSRange, _, _) -> Void in
            
            let token = text.substringWithRange(tokenRange)
            if(tag != nil){
                //println("text: \(token), tag: \(tag)")
                if let dic = countDic[tag]{
                    countDic[tag] = countDic[tag]! + 1
                }else{
                    countDic[tag] = 1
                }
            }
        })
        if(countDic.count == 0){
            
        } else if(countDic.count == 1){
            for (lang,count) in countDic{
                return lang
            }
        }else{
            var mostFrequentlyUsedLang = "en"
            var biggestCount = 0
            for (lang,count) in countDic{
                if biggestCount < count {
                    biggestCount = count
                    mostFrequentlyUsedLang = lang
                }
            }
            return mostFrequentlyUsedLang
        }
        return "en"
    }

    public class func getAllAvailableSchemes(lang:String){
        let schemes = NSLinguisticTagger.availableTagSchemesForLanguage(lang)
        println(schemes)
    }
}
