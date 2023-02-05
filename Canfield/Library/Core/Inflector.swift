//
//  Inflector.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation


// create an inflector class for strings like used in Ruby on Rails Active Support Inflector
// https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html

class Inflector {
    
    // MARK: - Pluralization
    
    // pluralize a word
    static func pluralize(_ word: String) -> String {
        if word.hasSuffix("s") {
            return word + "es"
        } else {
            return word + "s"
        }
    }
    
    // pluralize a word if count is not 1
    static func pluralize(_ word: String, count: Int) -> String {
        if count == 1 {
            return word
        } else {
            return pluralize(word)
        }
    }
    
    // MARK: - Singularization
    
    // singularize a word
    static func singularize(_ word: String) -> String {
        if word.hasSuffix("es") {
            return String(word.dropLast(2))
        } else {
            return String(word.dropLast())
        }
    }
    
    // MARK: - Titleization
    
    // titleize a word
    static func titleize(_ word: String) -> String {
        return word.capitalized
    }
    
    // titleize a word if count is not 1
    static func titleize(_ word: String, count: Int) -> String {
        if count == 1 {
            return word
        } else {
            return titleize(word)
        }
    }
    
    // MARK: - Humanization
    
    // humanize a word
    static func humanize(_ word: String) -> String {
        return word.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    // humanize a word if count is not 1
    static func humanize(_ word: String, count: Int) -> String {
        if count == 1 {
            return word
        } else {
            return humanize(word)
        }
    }
    
    // MARK: - Camelization
    
    // camelize a word
    static func camelize(_ word: String) -> String {
        return word.capitalized.replacingOccurrences(of: " ", with: "")
    }
    
    // camelize a word if count is not 1
    static func camelize(_ word: String, count: Int) -> String {
        if count == 1 {
            return word
        } else {
            return camelize(word)
        }
    }
    
    // MARK: - Underscoring
    
    // underscore a word
    static func underscore(_ word: String) -> String {
        return word.lowercased().replacingOccurrences(of: " ", with: "_")
    }

    // MARK: - Dasherization

    // dasherize a word
    static func dasherize(_ word: String) -> String {
        return word.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    // MARK: - Capitalization

    // capitalize a word
    static func capitalize(_ word: String) -> String {
        return word.capitalized
    }

    // MARK: - Ordinalization

    // ordinalize a number
    static func ordinalize(_ number: Int) -> String {
        let numberString = String(number)
        if numberString.hasSuffix("1") {
            return numberString + "st"
        } else if numberString.hasSuffix("2") {
            return numberString + "nd"
        } else if numberString.hasSuffix("3") {
            return numberString + "rd"
        } else {
            return numberString + "th"
        }
    }

    // MARK: - Tableization

    // tableize a word
    static func tableize(_ word: String) -> String {
        return pluralize(underscore(word))
    }

    // MARK: - Classification

    // classify a word
    static func classify(_ word: String) -> String {
        return camelize(singularize(word))
    }

    // MARK: - Foreign Key

    // foreign key for a word
    static func foreignKey(_ word: String) -> String {
        return underscore(classify(word)) + "_id"
    }   

    // MARK: - Sequence

    // sequence a word

    static func sequence(_ word: String, number: Int) -> String {
        return word + String(number)
    }

    // MARK: - Join

    // join a word

    static func join(_ word: String, number: Int) -> String {
        return word + String(number)
    }

    // MARK: - Join

    // join a word

    static func join(_ word: String, number: Int, separator: String) -> String {
        return word + separator + String(number)
    }

    // MARK: - Join

    // join a word

    static func join(_ word: String, number: Int, separator: String, suffix: String) -> String {
        return word + separator + String(number) + suffix
    }

    // MARK: - Join

    // join a word

    static func join(_ word: String, number: Int, separator: String, suffix: String, prefix: String) -> String {
        return prefix + word + separator + String(number) + suffix
    }
}

