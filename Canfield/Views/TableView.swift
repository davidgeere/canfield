//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI

struct TableView: View {
    var body: some View {
        ZStack(alignment: .top) {
            TableLayoutView()
        }
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
    }
}
