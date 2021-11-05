//
//  CustomGeneralFiller.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

class CustomGeneralFiller<S : DomainShape>: GeneralFiller<S> {
    required init(shape: S) {
        super.init(shape: shape)
    }
    // costom overrides
}
