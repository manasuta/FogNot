import WidgetKit
import SwiftUI

@main
struct FogNotWidgetBundle: WidgetBundle {
    var body: some Widget {
        FogNotWidget()
        // ⚠️ エラーが出る原因になるので、Control と LiveActivity は一旦消します
    }
}
