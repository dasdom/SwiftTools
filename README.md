# SwiftTools
Xcode extension for Swift code

Included tools:

## Align Equals

Before

```
enum Constants {
  static let github = "dasdom"
  static let twitterHandle = "dasdom"
  static let answerToEverything =       42
}
```

After

```
enum Constants {
  static let github             = "dasdom"
  static let twitterHandle      = "dasdom"
  static let answerToEverything = 42
}
```

## Copy Protocol Declarations For Selected Methods To Clipboard

Select these two methods

```
  func foo(a: String, b: Int) {
    // foobar
  }
  
  func bar(map: MKMapView) -> Int {
    return 0
  }
```

and use this tool. The following code is copied to the clipboard:

```
protocol <#Protocol Name#> {
  func foo(a: String, b: Int)
  func bar(map: MKMapView) -> Int
}
```

## Hex To UIColor

Select the following line in Xcode

```
    // #af33d1
```

and select the tool. The following line is added below the selected line:

```
let <#name#> = UIColor(red: 0.686, green: 0.200, blue: 0.820, alpha: 1.000)
```

## Sort Imports

Before

```
import MapKit
import Foo
import UIKit
import Bar
import Foundation
```

After

```
import Foundation
import MapKit
import UIKit

import Bar
import Foo
```

# Author

Dominik Hauser

[@dasdom](https://twitter.com/dasdom)

# Licence

MIT
