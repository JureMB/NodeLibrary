//
//  Defenitions.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 16/09/2021.
//
public protocol BaseGroupProtocol: Hashable, CaseIterable {}
public protocol GroupProtocol: BaseGroupProtocol {}
public protocol NoGroupProtocol: BaseGroupProtocol {}

public enum NoGroups: NoGroupProtocol {
}

typealias ErrorGroupProtocol = GroupProtocol&NoGroupProtocol

extension NoGroupProtocol {
    static func chekValidity(){}
}

extension NoGroupProtocol where Self: ErrorGroupProtocol {
    static func chekValidity(){
        if Self.self is NoGroups.Type {
            fatalError("'NoGroups' should not be extended to conform to GroupProtocol. To use groups create a new enum like 'enum MyGroups: Int, GroupProtocol {case group1, group2}' of raw type Int that conforms to GroupProtocol. Than create a new domain using let domain = Domain(withNodeGroups: MyGroups.self)")
        }
        fatalError("Object can't conform to both GroupProtocol and NoGroupProtocol.") // does not happen?
    }
}

func checkNoGroups(){
    NoGroups.chekValidity()
}
