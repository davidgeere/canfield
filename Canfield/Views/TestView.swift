//
//  TestView.swift
//  Canfield
//
//  Created by David Geere on 2/24/23.
//

import SwiftUI

struct TestItem: Identifiable, Equatable {
    
    var id = UUID()
    
    var suit: Suit
    var rank: Rank
    var facing: Face
    
    init(suit: Suit, rank: Rank, face: Face = .down) {
        self.suit = suit
        self.rank = rank
        self.facing = face
    }
}

class Stock: ObservableObject {
    @Published var pile: [TestItem]
    
    init() {
        self.pile = [TestItem]()
    }
    
    public func refresh() {
        self.objectWillChange.send()
    }
}

class Waste: ObservableObject {
    @Published var pile: [TestItem]
    
    init() {
        self.pile = [TestItem]()
    }
    
    public func refresh() {
        self.objectWillChange.send()
    }
}

class Foundation: ObservableObject {
    @Published var hearts: [TestItem]
    @Published var spades: [TestItem]
    @Published var clubs: [TestItem]
    @Published var diamonds: [TestItem]
    
    init() {
        self.hearts = [TestItem]()
        self.spades = [TestItem]()
        self.clubs = [TestItem]()
        self.diamonds = [TestItem]()
    }
    
    subscript(suit: Suit) -> [TestItem] {
        get {
            switch suit {
            case .hearts: return self.hearts
            case .spades: return self.spades
            case .clubs: return self.clubs
            case .diamonds: return self.diamonds
            }
        }
        
        set {
            switch suit {
            case .hearts: self.hearts = newValue
            case .spades: self.spades = newValue
            case .clubs: self.clubs = newValue
            case .diamonds: self.diamonds = newValue
            }
        }
    }
    
    public func refresh() {
        self.objectWillChange.send()
    }
}

class Tabeleau: ObservableObject {
    
    @Published var one: [TestItem]
    @Published var two: [TestItem]
    @Published var three: [TestItem]
    @Published var four: [TestItem]
    @Published var five: [TestItem]
    @Published var six: [TestItem]
    @Published var seven: [TestItem]
    
    init() {
        self.one = [TestItem]()
        self.two = [TestItem]()
        self.three = [TestItem]()
        self.four = [TestItem]()
        self.five = [TestItem]()
        self.six = [TestItem]()
        self.seven = [TestItem]()
    }
    
    public var open: Column? {
        for column in Column.allCases {
            guard self[column].isEmpty else { continue }
            
            return column
        }
        
        return nil
    }
    
    public var hasOpen: Bool {
        for column in Column.allCases {
            guard self[column].isEmpty else { continue }
            
            return true
        }
        
        return false
    }
    
    subscript(column: Column) -> [TestItem] {
        get {
            switch column {
            case .one: return self.one
            case .two: return self.two
            case .three: return self.three
            case .four: return self.four
            case .five: return self.five
            case .six: return self.six
            case .seven: return self.seven
            }
        }
        
        set {
            switch column {
            case .one: self.one = newValue
            case .two: self.two = newValue
            case .three: self.three = newValue
            case .four: self.four = newValue
            case .five: self.five = newValue
            case .six: self.six = newValue
            case .seven: self.seven = newValue
            }
        }
    }
    
    public func refresh() {
        self.objectWillChange.send()
    }
}

class TestManager: ObservableObject {
    
    @Published var stock: Stock
    @Published var waste: Waste
    @Published var foundation: Foundation
    @Published var tableau: Tabeleau
    
    init() {
        self.stock = Stock()
        self.waste = Waste()
        self.foundation = Foundation()
        self.tableau = Tabeleau()
    }
    
    func selectItem(_ item: TestItem) {
        if let selectedItem = selectedItem {
            if selectedItem == item {
                self.selectedItem = nil
            } else {
                return
            }
        } else {
            self.selectedItem = item
        }
    }
    
    @Published var selectedItem: TestItem? = nil
    
    public func refresh() {
        self.objectWillChange.send()
    }
}

struct TestItemView: View {

    @State var item: TestItem
    @State var numberOfShakes: CGFloat
    
    private var onTapAction: ((TestItemView) -> Void)?
    
    private let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    
    var ns: Namespace.ID
    @Namespace private var card
    
    init(item: TestItem, in namespace: Namespace.ID) {
        self._item = State(initialValue: item)
        self._numberOfShakes = State(initialValue: 0)
        
        self.axis = (x: .zero, y: 1, z: .zero)
        self.ns = namespace
    }
    
    var body: some View {
        
        Group {
            switch item.facing {
            case .up:
                VectorImage("decks/chunky/\(item.suit.name)/\(item.rank.name)")
                    .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                    .matchedGeometryEffect(id: item.id, in: card)
                    .rotation3DEffect(.degrees(180), axis: self.axis)
                    
            case .down:
                VectorImage("decks/chunky/back")
                    .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                    .matchedGeometryEffect(id: item.id, in: card)
                    .rotation3DEffect(.degrees(0), axis: self.axis)
            }
        }
        .modifier(ShakeEffect(shake_number: numberOfShakes))
        
        .onTapGesture {
            if let onTapAction {
                onTapAction(self)
            }
        }
        .rotation3DEffect(item.facing == .up ? .degrees(180): .zero, axis: self.axis)
        .animation(.easeIn(duration: 0.3), value: item.facing)
        .matchedGeometryEffect(id: item.id, in: ns)//, isSource: manager.selectedItem != item)
    }
    
    public func onTap(_ handler: @escaping (TestItemView) -> Void) -> TestItemView {
        var new = self
        new.onTapAction = handler
        return new
    }
}

struct StockPileView: View {
    
    @EnvironmentObject var manager: TestManager
    
    var ns: Namespace.ID
    
    var body: some View {
        
        ZStack{
            
            VectorImage("depot/reload")
                .foregroundColor(.white.opacity(0.4))
                .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    while var card = manager.waste.pile.popLast() {
                        
                        card.facing = .down
                        
                        manager.stock.pile.append(card)
                        
                        manager.refresh()
                    }
                }
            
            ForEach($manager.stock.pile) { item in
                
                var item = item.wrappedValue
                
                TestItemView(item: item, in: ns)
                    .onTap { view in
                        withAnimation(.spring()) {
                            
                            guard !manager.waste.pile.contains(where: { return $0.id == item.id } ) else { return }
                            
                            manager.selectItem(item)
                            
                            manager.stock.pile.removeAll(where: {  return $0.id == item.id })
                            
                            item.facing = .up
                            
                            manager.waste.pile.append(item)
                            
                            manager.refresh()
                            
                        }
                    }
            }
        }
    }
}

struct WastePileView: View {
    
    @EnvironmentObject var manager: TestManager
    
    var ns: Namespace.ID
    
    var body: some View {
        
        ZStack{
            
            Color.clear // spacer
                .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            ForEach($manager.waste.pile) { item in
                
                var item = item.wrappedValue
                
                TestItemView(item: item, in: ns)
                    .onTap { view in
                        
                        withAnimation(.spring()) {
                            
                            switch item.rank {
                            case .ace: // if it's an ace, place it in the right foundation
                                
                                manager.waste.pile.removeAll(where: {  return $0.id == item.id })
                                
                                item.facing = .up
                                
                                manager.foundation[item.suit].append(item)
                                
                                manager.refresh()
                                
                                return
                                
                            case .king: // if it's a king place it in an empty tableau
                                
                                if var column = manager.tableau.open {
                                    
                                    manager.waste.pile.removeAll(where: {  return $0.id == item.id })
                                    
                                    manager.tableau[column].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                    
                                } else {
                                    
                                    guard let last = manager.foundation[item.suit].last, last.rank == .queen else { break }
                                    
                                    manager.waste.pile.removeAll(where: {  return $0.id == item.id })
                                    
                                    manager.foundation[item.suit].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                }
                                
                            default: // anything else, see where there is a match and move it there
                                
                                if let last = manager.foundation[item.suit].last, last.rank == item.rank.previous {
                                    
                                    manager.waste.pile.removeAll(where: {  return $0.id == item.id })
                                    
                                    manager.foundation[item.suit].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                    
                                } else {
                                    for column in Column.allCases {
                                        
                                        guard let last = manager.tableau[column].last, last.rank == item.rank.next, last.suit.pair != item.suit.pair else { continue }
                                        
                                        manager.waste.pile.removeAll(where: {  return $0.id == item.id })
                                        
                                        manager.tableau[column].append(item)
                                        
                                        manager.refresh()
                                        
                                        return
                                    }
                                }
                            }
                        }
                        
                        withAnimation(.easeIn(duration: 0.1)) {
                            view.numberOfShakes = 10
                        }
                        
                        view.numberOfShakes = 0
                    }
            }
        }
    }
}

struct FoundationPileView: View {
    
    @EnvironmentObject var manager: TestManager
    
    var suit: Suit
    
    
    var ns: Namespace.ID
    
    var body: some View {
        
        ZStack{
            
            VectorImage("depot/\(suit.name)")
                .foregroundColor(.white.opacity(0.4))
                .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            ForEach($manager.foundation[suit]) { item in
                
                var item = item.wrappedValue
                
                TestItemView(item: item, in: ns)
                    .onTap { view in
                        
                        withAnimation(.spring()) {
                            
                            switch item.rank {
                            case .king: // if it's a king place it in an empty tableau
                                
                                if var column = manager.tableau.open {
                                    
                                    manager.foundation[suit].removeAll(where: {  return $0.id == item.id })
                                    
                                    manager.tableau[column].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                    
                                }
                                
                            default: // anything else, see where there is a match and move it there
                                
                                for column in Column.allCases {
                                    
                                    guard let last = manager.tableau[column].last, last.rank == item.rank.next, last.suit.pair != item.suit.pair else { continue }
                                    
                                    manager.foundation[suit].removeAll(where: {  return $0.id == item.id })
                                    
                                    manager.tableau[column].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                }
                            }
                        }
                        
                        withAnimation(.easeIn(duration: 0.1)) {
                            view.numberOfShakes = 10
                        }
                        
                        view.numberOfShakes = 0
                    }
                //                .rotation3DEffect(item.facing == .up ? .degrees(180): .zero, axis: (x: .zero, y: 1, z: .zero))
                //                .matchedGeometryEffect(id: item.id, in: ns, isSource: manager.selectedItem != item)
            }
        }
    }
}

struct TableauPileView: View {
    
    @EnvironmentObject var manager: TestManager
    
    var column: Column
    
    var ns: Namespace.ID
    
    var body: some View {
        
        ZStack{
            
            VectorImage("depot/open")
                .foregroundColor(.white.opacity(0.4))
                .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: -180) {
                ForEach($manager.tableau[column]) { item in
                    
                    var item = item.wrappedValue
                    
                    TestItemView(item: item, in: ns)
                        .onTap { view in
                            
                            withAnimation(.spring()) {
                                
                                switch item.rank {
                                case .ace: // if it's an ace, place it in the right foundation
                                    
                                    manager.tableau[column].removeAll(where: {  return $0.id == item.id })
                                    
                                    if var last = manager.tableau[column].last {
                                        print("b last", last)
                                        
                                        last.facing = .up
                                        
                                        manager.tableau.refresh()
                                        
                                        print("a last", last)
                                    }
                                    
                                    item.facing = .up
                                    
                                    manager.foundation[item.suit].append(item)
                                    
                                    manager.refresh()
                                    
                                    return
                                    
                                case .king: // if it's a king place it in an empty tableau
                                    
                                    if var open = manager.tableau.open {
                                        
                                        manager.tableau[column].removeAll(where: {  return $0.id == item.id })
                                        
                                        if var last = manager.tableau[column].last {
                                            print("b last", last)
                                            
                                            last.facing = .up
                                            
                                            manager.tableau.refresh()
                                            
                                            print("a last", last)
                                        }
                                        
                                        manager.tableau[open].append(item)
                                        
                                        manager.refresh()
                                        
                                        return
                                        
                                    } else {
                                        
                                        guard let last = manager.foundation[item.suit].last, last.rank == .queen else { break }
                                        
                                        manager.tableau[column].removeAll(where: {  return $0.id == item.id })
                                        
                                        if var last = manager.tableau[column].last {
                                            print("b last", last)
                                            
                                            last.facing = .up
                                            
                                            manager.tableau.refresh()
                                            
                                            print("a last", last)
                                        }
                                        
                                        manager.foundation[item.suit].append(item)
                                        
                                        manager.refresh()
                                        
                                        return
                                    }
                                    
                                default: // anything else, see where there is a match and move it there
                                    
                                    if let last = manager.foundation[item.suit].last, last.rank == item.rank.previous {
                                        
                                        manager.tableau[column].removeAll(where: {  return $0.id == item.id })
                                        
                                        if var last = manager.tableau[column].last {
                                            print("b last", last)
                                            
                                            last.facing = .up
                                            
                                            manager.tableau.refresh()
                                            
                                            print("a last", last)
                                        }
                                        
                                        manager.foundation[item.suit].append(item)
                                        
                                        manager.refresh()
                                        
                                        return
                                        
                                    } else {
                                        for column in Column.allCases {
                                            
                                            guard column != self.column else { continue }
                                            
                                            guard let last = manager.tableau[column].last, last.rank == item.rank.next, last.suit.pair != item.suit.pair else { continue }
                                            
                                            manager.tableau[column].removeAll(where: {  return $0.id == item.id })
                                            
                                            if var last = manager.tableau[column].last {
                                                
                                                print("b last", last)
                                                
                                                last.facing = .up
                                                
                                                manager.tableau.refresh()
                                                
                                                print("a last", last)
                                            }
                                            
                                            manager.tableau[column].append(item)
                                            
                                            manager.refresh()
                                            
                                            return
                                        }
                                    }
                                }
                            }
                            
                            withAnimation(.easeIn(duration: 0.1)) {
                                view.numberOfShakes = 10
                            }
                            
                            view.numberOfShakes = 0
                        }
                    //                .rotation3DEffect(item.facing == .up ? .degrees(180): .zero, axis: (x: .zero, y: 1, z: .zero))
                    //                .matchedGeometryEffect(id: item.id, in: ns, isSource: manager.selectedItem != item)
                }
            }
        }
    }
}

struct TestView: View {
    
    @StateObject var manager = TestManager()
    @Namespace private var namespace
    
    var body: some View {
        
        
        VStack(alignment: .trailing, spacing: 0) {
            VStack(spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.MARGIN / GLOBALS.CARD.WIDTH ))) {
                HStack(alignment: .top, spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.SPACING / GLOBALS.CARD.WIDTH ))) {
                    
                    StockPileView(ns: namespace)
                        .environmentObject(manager)
                    
                    WastePileView(ns: namespace)
                        .environmentObject(manager)
                    
                    Color.clear // spacer
                        .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    ForEach(Suit.allCases) { suit in
                        FoundationPileView(suit: suit, ns: namespace)
                            .environmentObject(manager)
                    }
                }
                
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(alignment: .top, spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.SPACING / GLOBALS.CARD.WIDTH )) ) {
                        ForEach(Column.allCases) { column in
                            TableauPileView(column: column, ns: namespace)
                                .environmentObject(manager)
                        }
                    }
                }
                Spacer()
            }
            .padding((Deck.instance.size.width * ( GLOBALS.TABLE.MARGIN / GLOBALS.CARD.WIDTH )))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GLOBALS.TABLE.COLOR)
        .coordinateSpace(name: GLOBALS.TABLE.NAME)
        .onAppear {
           for suit in Suit.allCases {
                for rank in Rank.allCases {
                    self.manager.stock.pile.append(TestItem(suit: suit, rank: rank))
                }
            }
            
            self.manager.stock.pile.shuffle()
            
            self.manager.refresh()
            
            for column in Column.allCases {
                for i in 1...column.value {
                    guard var card = self.manager.stock.pile.popLast() else { continue }
                    
                    if i == column.value {
                        card.facing = .up
                    }
                    
                    manager.tableau[column].append(card)
                    
                    self.manager.refresh()
                }
            }
            
            self.manager.refresh()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
