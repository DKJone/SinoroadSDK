//
//  AddressXMLParser.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// 省
public struct Province {
    public let id: Int
    public let name: String
    public var cities: [City]
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.cities = [City(id: -2, name: "全部")]
    }
    
    public mutating func addCity(_ city: City) {
        cities.append(city)
    }
}

/// 市
public struct City {
    public let id: Int
    public let name: String
    public var regions: [Region]
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.regions = [Region(id: -3, name: "全部")]
    }
    
    public mutating func addRegion(_ region: Region) {
        regions.append(region)
    }
}

/// 区
public struct Region {
    public let id: Int
    public let name: String
}

/// 区域数据
public var provinces = [Province(id: -1, name: "全部")]

/// 地址解析器
public final class AddressXMLParser: NSObject {
    var parser: XMLParser!
    var curProvince: Province!
    var curCity: City!
    var curRegion: Region!
    
    /// 使用地址数据文件创建解析器，默认使用APP自带的地址数据
    public init?(file: URL? = nil) {
        super.init()
        
        let xmlFileURL: URL
        if let file = file {
            xmlFileURL = file
        } else { // 使用APP自带的地址数据
            xmlFileURL = Bundle.main.url(forResource: "area", withExtension: ".xml")!
        }
        
        guard let data = try? Data(contentsOf: xmlFileURL) else {
            print("地址解析错误")
            return nil
        }
        
        parser = XMLParser(data: data)
        parser.delegate = self
    }
    
    /// 开始解析地址数据
    public func parse() {
        parser.parse()
    }
    
    fileprivate static let kElementProvince = "province"
    fileprivate static let kElementCity = "city"
    fileprivate static let kElementDistinct = "distinct"
}

// MARK: - XMLParserDelegate
extension AddressXMLParser: XMLParserDelegate {
    
    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case AddressXMLParser.kElementProvince: curProvince = create(with: attributeDict, constructor: Province.init(id:name:))
        case AddressXMLParser.kElementCity:     curCity = create(with: attributeDict, constructor: City.init(id:name:))
        case AddressXMLParser.kElementDistinct: curRegion = create(with: attributeDict, constructor: Region.init(id:name:))
        default: ()
        }
    }
    
    public func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        switch elementName {
        case AddressXMLParser.kElementProvince: provinces.append(curProvince)
        case AddressXMLParser.kElementCity:     curProvince.addCity(curCity)
        case AddressXMLParser.kElementDistinct: curCity.addRegion(curRegion)
        default: ()
        }
    }
    
    private func create<T>(with data: [String: String], constructor: (Int, String) -> T) -> T {
        return constructor(Int(data["id"]!)!, data["name"]!)
    }
}
