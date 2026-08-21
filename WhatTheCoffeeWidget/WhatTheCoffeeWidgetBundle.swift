import WidgetKit
import SwiftUI

@main
struct WhatTheCoffeeWidgetBundle: WidgetBundle {
  var body: some Widget {
    WhatTheCoffeeWidget()
    TodayCoffeeWidget()
  }
}
