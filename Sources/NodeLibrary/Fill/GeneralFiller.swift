//
//  GeneralFiller.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

public class GeneralFiller<S: DomainShape>: BaseFiller<S> {
    let shape: S
    
    required init(shape: S) {
        self.shape = shape
    }
    
    override func fillInterior<E>(of domain: Domain<E,S>,by fillBy: FillBy) {
        switch fillBy {
        case .step(let step):
            print("fill step", step)
            let domainArea: Double = (shape.bounds.xHigh - shape.bounds.xLow) * (shape.bounds.yHigh - shape.bounds.yLow)
            let stepArea: Double = step * step
            let N = Int(domainArea / stepArea)
            print("N = ", N)
            for _ in 1...N {
                var point: Point? = nil
                while point == nil {
                    let x = Double.random(in: shape.bounds.xLow...shape.bounds.xHigh)
                    let y = Double.random(in: shape.bounds.yLow...shape.bounds.yHigh)
                    point = .init(x: x, y: y)
                    if !shape.interiorContains(point: point!) { point = nil }
                }
                domain.addNode(.init(at: point!, nodeKind: .interior, group: nil))
            }
        case .density(let density):
            print("print dens", density)
            fatalError("DefaultFiller not implemented for density.")
        }
        
    }
    
    override func fillBoundary<E>(of domain: Domain<E,S>,by fillBy: FillBy)  {
        switch fillBy {
        case .step(let step):
            print("fill step", step)
        case .density(let density):
            print("print dens", density)
        }
        fatalError("DefaultFiller not implemented.")
    }
}
