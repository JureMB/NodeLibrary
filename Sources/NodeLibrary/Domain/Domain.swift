//
//  Domain.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 14/09/2021.
//
import Foundation

enum DomainError: Error {
    case InvalidNodeIndexError(String)
    case InvalidNodeIDError(String)
}

public typealias ID = UUID
public typealias NodeKindSequence<E: BaseGroupProtocol> = LazyMapSequence<LazyFilterSequence<RefferenceArray<Int>>, NodeData<E>>
public typealias AllNodeSequence<E: BaseGroupProtocol> = FlattenSequence<[NodeKindSequence<E>]>
public typealias FilteredAllNodeSequence<E: BaseGroupProtocol> = FlattenSequence<[LazyFilterSequence<NodeKindSequence<E>>]>

public class Domain<E: BaseGroupProtocol, S: BaseDomainShape> {
    private var _nodes = [Node<E>?]()
    private let _interiorIndices = RefferenceArray<Int>()
    private let _boundaryIndices = RefferenceArray<Int>()
    private var _nodeDictionary = [UUID: Int]()
    private var _neighbours: [[Int]]? = nil
    private var _deleteCount = 0
//    var shouldRebildDomainStorage: Bool { _deleteCount >  count / 2}
    private let groupType: E.Type
    private let _shape: S
    private var _filler: BaseFiller<S>
    private var _hasSolver: Bool
//    private var _deactivated = false // TODO add checks
    
    public var count: Int { interiorCount + boundaryCount }
    public var interiorCount: Int {_interiorIndices.count}
    public var boundaryCount: Int {_boundaryIndices.count}
    
    private init(groupType: E.Type, shape: S, filler: BaseFiller<S>) {
        checkNoGroups()
        self.groupType = groupType
        self._shape = shape
        self._filler = filler
        self._hasSolver = false
    }
    
    public convenience init(groups groupType: E.Type, shape: S) where E: GroupProtocol, S:Fillable{
        self.init(groupType: groupType, shape: shape, filler: shape.getFiller())
    }
    
    public convenience init(shape: S) where E==NoGroups, S: Fillable{
        self.init(groupType: NoGroups.self, shape: shape, filler: shape.getFiller())
    }
    
    public convenience init(groups groupType: E.Type) where E: GroupProtocol, S==NoShape{
        self.init(groupType: groupType, shape: NoShape(), filler: BaseFiller())
    }
    
    public convenience init() where E == NoGroups, S == NoShape{
        self.init(groupType: NoGroups.self, shape: NoShape(), filler: BaseFiller())
    }
    
    internal func getShape() -> S {
        return self._shape
    }
    
    @discardableResult
    public func addNode(_ node: Node<E>) -> UUID {
//        assert(!_deactivated)
        guard !isLocked() else {
            fatalError("Can't add or remove nodes once solver is set.")
        }
        _nodes.append(node)
        let id = node.id
        let index = _nodes.indices.last! //node was added, so this is valid always
        _nodeDictionary[node.id] = index
        switch node.kind {
        case .interior:
            _interiorIndices.append(index)
        case .boundary:
            _boundaryIndices.append(index)
        }
        return id
    }
    
    public func getNode(withID id: UUID) throws -> Node<E> {
        if let internalIndex = _nodeDictionary[id] {
            if let node = _nodes[internalIndex] {
                return node
            } else {
                throw DomainError.InvalidNodeIndexError("Node was deleted.")
            }
        } else {
            throw DomainError.InvalidNodeIDError("Provided id does not exist. If node with this id was deleted, the id was removed when the data did an automatic rebild to sustain optimal performance. ")
        }
    }
    
    public func getNode(withIndex index: Int) -> Node<E> {
        return _nodes[index]!
    }
    
    public func setNode(withID id: UUID, to newValue: Node<E>) throws {
        guard !isLocked() else {
            fatalError("Can't add or remove nodes once solver is set.")
        }
        if let internalIndex = _nodeDictionary[id] {
            if _nodes[internalIndex] != nil {
                _nodes[internalIndex] = newValue
            } else {
                throw DomainError.InvalidNodeIndexError("Target node was deleted. Add a new node instead.")
            }
        } else {
            throw DomainError.InvalidNodeIDError("Provided id does not exist. If node with this id was deleted, the id was removed when the data did an automatic rebild to sustain optimal performance. Add a new node instead.")
        }
    }
    
    @discardableResult
    public func addInteriorNode(at point: Point) -> UUID where E==NoGroups {
        let node = Node<E>(at: point, nodeKind: .interior)
        return addNode(node)
    }
    
    @discardableResult
    public func addBoundaryNode(at point: Point) -> UUID where E==NoGroups{
        let node = Node<E>(at: point, nodeKind: .boundary)
        return addNode(node)
    }
    
//    func addInteriorNode(at point: Point, inGroup group: E? = nil) where E: GroupProtocol {
//        let node = Node(at: point, nodeKind: .interior, group: group)
//        addNode(node)
//    }
//
//    func addBoundaryNode(at point: Point, inGroup group: E? = nil) where E: GroupProtocol {
//        let node = Node<E>(at: point, nodeKind: .boundary, group: group)
//        addNode(node)
//    }
    
    public func removeNode(withID id: UUID) throws {
//        guard(!_deactivated) else {
//            fatalError("This domain was replaced when 'addShape' or 'addGroups' was called. Use the new domain that was returned by 'addShape' or 'addGroups'.")
//        }
        guard !isLocked() else {
            fatalError("Can't add or remove nodes once solver is set.")
        }
        if let internalIndex = _nodeDictionary[id] {
            if _nodes[internalIndex] != nil {
                _nodes[internalIndex] = nil
                _deleteCount += 1
            } else {
                throw DomainError.InvalidNodeIndexError("Node was already deleted.")
            }
            
        } else {
            throw DomainError.InvalidNodeIDError("Node with provided id never existed or was already deleted before datastructure automaticly rebilt itself for performance reasons.")
        }
    }
    
    func rebuildDomainStorage() {
//        assert(!_deactivated)
        #if DEBUG
        print("rebuildting...")
        #endif
        // good strategy, we only care about absolute time. Random rebilds do not hurt us.
        _deleteCount = 0
        let compactNodes: [Node] = _nodes.compactMap{ $0 } // removes empty (nil) elements and writes new dense array
        _nodes = compactNodes
        _nodeDictionary.removeAll()
        _boundaryIndices.removeAll()
        _interiorIndices.removeAll()
        for (index, node) in _nodes.enumerated() {
            _nodeDictionary[node!.id] = index // nodes is dense
            switch node!.kind {
            case .interior:
                _interiorIndices.append(index)
            case .boundary:
                _boundaryIndices.append(index)
            }
        }
    }
    
    internal func status() {
//        assert(!_deactivated)
        print("nodes:", _nodes)
        print("boundary:", _boundaryIndices)
        print("interior:", _interiorIndices)
    }
}
// Support for itterating over nodes.
extension Domain {
    
    private func _nodeSequence(_ kind: NodeKind) ->  NodeKindSequence<E> {
//        assert(!_deactivated)
        switch kind {
        case .boundary:
            return _boundaryIndices.lazy.filter {self._nodes[$0] != nil}.map { (i) -> NodeData<E> in
//                assert(!self._deactivated)
                if let node = self._nodes[i] {return NodeData(index: i, node: node)}
                else { fatalError("Internal error, \(i) place in '_nodes' should contain a valid 'Node' object. ")}
            }
        case .interior:
            return _interiorIndices.lazy.filter {self._nodes[$0] != nil}.map { (i) -> NodeData<E> in
//                assert(!self._deactivated)
                if let node = self._nodes[i] {return NodeData(index: i, node: node)}
                else { fatalError("Internal error, \(i) place in '_nodes' should contain a valid 'Node' object. ")}
            }
        }
    }
    
    public func interior() -> NodeSequence<E, NodeKindSequence<E>> {
//        assert(!_deactivated)
        return NodeSequence(groupType: E.self, sequence: _nodeSequence(.interior))
    }
    
    public func boundary() -> NodeSequence<E, NodeKindSequence<E>> {
//        assert(!_deactivated)
        return NodeSequence(groupType: E.self, sequence: _nodeSequence(.boundary))
    }
    
    public func all() -> NodeSequence<E, AllNodeSequence<E>> {
//        assert(!_deactivated)
        return NodeSequence(groupType: E.self, sequence: [_nodeSequence(.boundary), _nodeSequence(.interior)].joined())
    }
    
    public func group(_ group: E?) -> NodeSequence<E, FilteredAllNodeSequence<E>> where E: GroupProtocol {
//        assert(!_deactivated)
        let interior = _nodeSequence(.interior).lazy.filter { group == $0.group }
        let boundary = _nodeSequence(.boundary).lazy.filter { group == $0.group }
        return NodeSequence(groupType: E.self, sequence: [boundary, interior].joined())
    }
}

// Support for Domain fillers
extension Domain where S: Fillable {
    public func fillInterior(by fillBy: FillBy) {
//        assert(!_deactivated)
        assert(_nodes.isEmpty)
        _filler.fillInterior(of: self, by: fillBy)
    }
    
    public func fillBoundary(by fillBy: FillBy) {
        assert(_nodes.isEmpty)
        _filler.fillBoundary(of: self, by: fillBy)
    }
    
    public func fill(by fillBy: FillBy) {
        assert(_nodes.isEmpty)
        _filler.fillInterior(of: self, by: fillBy)
        _filler.fillBoundary(of: self, by: fillBy)
    }
    
    public func setFiller(_ fillerType: SwitchFiller<S>) where S: DomainShape{
        switch fillerType {
        case .generalFiller:
            self._filler = GeneralFiller(shape: _shape)
        case .seccondGeneralFiller:
            self._filler = CustomGeneralFiller(shape: _shape)
        case .customGeneralFiller(let fillerType):
            self._filler = fillerType.init(shape: _shape)
        case .shapeSpecifiedFiller:
            self._filler = _shape.getFiller()
            
            if self._filler is GeneralFiller<S> {
                print("Shape does not specify a costum filler. Using GeneralFiller instaed.")
            }
        case .completlyCostomFiller(let filler):
            self._filler = filler
        }
    }
    
    public func setCostomFiller(_ filler: BaseFiller<S>) where S: Fillable{
//        assert(!_deactivated)
        self._filler = filler
    }
}

// support for shape aware domain
extension Domain where S: DomainShape {
    public func contains(point: Point) -> Bool {
//        assert(!_deactivated)
        return _shape.interiorContains(point: point)
    }
    
    public func boundaryContains(point: Point) -> Bool {
//        assert(!_deactivated)
        return _shape.boundaryContains(point: point)
    }
}

extension Domain {
    private func findNeigboursForNode(index: Int, number: Int) -> [Int] {
        return Array(repeating: 0, count: number)
    }
    
    internal func getNeigboursIndices(forIndex index: Int) -> [Int] {
        guard let _neighbours = _neighbours else {
            fatalError()
        }
        return _neighbours[index]
    }
    
    public func setNeighbours(number: Int) {
        _neighbours = .init(repeating: [], count: _nodes.count)
        for (index, _) in _nodes.enumerated() {
            _neighbours![index].append(contentsOf: findNeigboursForNode(index: index, number: number))
        }
    }
}

extension Domain {
    public func makeSolver<F>(forScalarFields scalar: F.Type, forVectorFields vector: Fields2D.Type? = nil) -> Solver<E, S, F>{
        guard !_hasSolver else {
            fatalError()
        }
        rebuildDomainStorage()// optimises storage. No changes alowed after this step.
        let solver = Solver(domain: self, scalarFields: scalar, vectorFields: vector)
        _hasSolver = true
        return solver
    }
    
    public func isLocked() -> Bool {
        return _hasSolver
    }
}


