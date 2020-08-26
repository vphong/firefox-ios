/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WidgetKit
import SwiftUI
import Shared

struct Provider: TimelineProvider {
    public typealias Entry = SimpleEntry

    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
}

struct SearchQuickLinksEntryView : View {
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 8.0) {
                ImageButtonWithLabel(isSmall: false, link: .search)
                ImageButtonWithLabel(isSmall: false, link: .privateSearch)
            }
            HStack(alignment: .top, spacing: 8.0) {
                ImageButtonWithLabel(isSmall: false, link: .copiedLink)
                ImageButtonWithLabel(isSmall: false, link: .closePrivateTabs)
            }
        }
        .padding(10.0)
        .background(Color("backgroundColor"))
    }
}

struct SearchQuickLinksWigdet: Widget {
    private let kind: String = "Quick Actions - Medium"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(), placeholder: SearchQuickLinksEntryView()) { entry in
            SearchQuickLinksEntryView()
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName(String.QuickActionsGalleryTitle)
        .description(String.FirefoxShortcutGalleryDescription)
    }
}

struct SearchQuickLinksPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .small)

            SearchQuickLinksEntryView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .accessibilityLarge)
        }
    }
}
