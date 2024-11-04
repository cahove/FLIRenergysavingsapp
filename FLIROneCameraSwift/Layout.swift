//
//  ContentView.swift
//  Roof Inspection
//
//  Created by Christopher Hove on 29/08/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack
        {
            
        
                VStack
                {
                    Text("Roof Inspection")
                        .font(.system(size: 40, weight: .light, design: .default))
                        .padding()
                    
                    Spacer()
                    
                    Image(systemName: "globe")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                }
    }
        
    }
}

// MARK: - Section 2

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
