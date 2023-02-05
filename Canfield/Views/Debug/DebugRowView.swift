//
//  DebugRowView.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import SwiftUI

struct DebugRowView: View {
    
    typealias Row = (key: String, values: [String])
    
    private var rows: [Row]
    
    init(_ rows:Row...) {
        self.rows = rows
    }
    
    init(_ key: String, values: [String] = []) {
        self.rows = [Row(key: key, values: values)]
    }
    
    init(_ key: String, value: String = .empty) {
        self.rows = [Row(key: key, values: [value])]
    }
    
    private let key_font:Font = .custom("SF Mono Bold", size: 10.0)
    private let value_font:Font = .custom("SF Mono Regular", size: 10.0)
    
    var body: some View {
        
        ForEach(self.rows.indices, id: \.self) { r in
            HStack(spacing: 1) {
                
                Text(rows[r].key).font(key_font).bold()
                
                
                if rows[r].values.count > 0 {
                    if rows[r].values.count == 1 {
                        Text(rows[r].values.joined(separator: "")).font(value_font)
                    } else {
                        Text("(" + rows[r].values.joined(separator: ", ") + ")").font(value_font)
                    }
                }
            }
            .foregroundColor(.red)
        }
    }
}

struct DebugRowView_Previews: PreviewProvider {
    static var previews: some View {
        DebugRowView("key", value: "value")
    }
}
