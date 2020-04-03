//  Created by dasdom on 22.02.20.
//  Copyright © 2020 dasdom. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("A selection of Xcode tools for Swift code.")
        .font(.headline)
        .padding([.top, .bottom])
      Text("""
The following tools are included:

- Align equals
- Color Literal to UIColor
- Copy Protocol Declarations For Selected Methods To Clipboard
- Hex to UIColor
- UIColor to Color Literal
- Sort Imports
""")
      Text("\nTo activate the tools, open System Preferences > Extensions > Xcode Source Editor and check the check box at Bazinga.")
      Spacer()
      Text("You can find the code for this Xcode extension at: https://github.com/dasdom/SwiftTools")
      Text("dominik.hauser@dasdom.de")
      }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
