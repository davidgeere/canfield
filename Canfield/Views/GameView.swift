//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @EnvironmentObject private var game: Game
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack {
//            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
//                Text("iPhone Portrait")
//            } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
//                Text("iPhone Landscape")
//            } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
//                Text("Small iPhone Landscape")
//            } else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
//                Text("iPad Portrait/Landscape")
//            }
            
            HeaderView()
            ZStack(alignment: .top) {
                TableView()
                    .environmentObject(self.game)
                
                CardsView()
                    .environmentObject(self.game)
            }
            .size(for: .full)
        }
        .overlay(alignment: .bottom) {
            ActionsView()
                .environmentObject(self.game)
        }
        .size(for: .full)
        .background(GLOBALS.TABLE.COLOR)
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        
        GameView()
            .environmentObject(Game.preview)
        
        
    }
}

/*
 In your GameView, add a withAnimation block around calls to game.move() to animate card movements between piles:
 
 // Move a card to a foundation pile
 game.move(card: card, from: sourcePile, to: .foundation(destinationIndex))
 withAnimation(.spring()) {
     // Update the source pile and destination pile views
     updatePileViews(pile: sourcePile)
     updatePileViews(pile: .foundation(destinationIndex))
 }

 In your CardView, use a @State variable to animate the position of the card when it's dragged to a new pile. For example, you could add a @State var offset: CGSize = .zero property to CardView, and then use the offset in the position modifier to animate the card position:
 
 struct CardView: View {
     var card: Card
     var isSelected: Bool
     var isDraggable: Bool
     var offset: CGSize = .zero
     
     var body: some View {
         let cardColor = card.suit.color()
         let foregroundColor = isSelected ? Color.white : cardColor
         
         ZStack {
             RoundedRectangle(cornerRadius: 10)
                 .fill(Color.white)
                 .overlay(
                     RoundedRectangle(cornerRadius: 10)
                         .stroke(lineWidth: isSelected ? 3 : 1)
                 )
             VStack {
                 Text(card.displayText())
                     .font(.system(size: 20))
                     .foregroundColor(foregroundColor)
                 Spacer()
                 Text(card.displaySuit())
                     .font(.system(size: 20))
                     .foregroundColor(cardColor)
             }
             .padding(8)
         }
         .foregroundColor(cardColor)
         .frame(width: 80, height: 120)
         .position(x: layout.cardPosition.x + offset.width, y: layout.cardPosition.y + offset.height)
         .gesture(
             isDraggable ?
                 DragGesture(minimumDistance: 0)
                     .onChanged { value in
                         offset = value.translation
                     }
                     .onEnded { value in
                         withAnimation(.spring()) {
                             // Move the card to a new pile
                             // ...
                         }
                         offset = .zero
                     }
                 : nil
         )
     }
 }

 
 Finally, in your LayoutView, use the offset parameter of CardView to animate card movements between piles. For example, you could add a var offset: CGPoint = .zero property to CardView, and then use the offset to animate the position of the card in the CardView:
 
 struct LayoutView: View {
     // ...
     func cardView(for card: Card, in pile: Pile, index: Int) -> some View {
         let isSelected = game.isSelected(card: card)
         let isDraggable = game.isDraggable(card: card, in: pile)
         let offset = game.isDragging(card: card) ? game.dragOffset : .zero
         
         return CardView(card: card, isSelected: isSelected, isDraggable: isDraggable, offset: offset)
     }
 }

 With these modifications, you should be able to animate card movements between piles using the withAnimation modifier and the offset parameter in your views.
 */
