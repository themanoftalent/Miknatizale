import SwiftUI

public enum NavigationItem: Hashable {
    case command(SnapAction)
    case general
}

public class PreferencesViewModel: ObservableObject {
    @Published public var selectedItem: NavigationItem? = .command(.left)
    @Published public var searchText: String = ""

    public init() {}
}

public struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @ObservedObject var settings = UserSettings.shared

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 300)
        } detail: {
            VStack(spacing: 0) {
                PermissionsBannerView()

                switch viewModel.selectedItem {
                case .command(let action):
                    CommandDetailView(action: action)
                case .general:
                    GeneralSettingsView()
                case .none:
                    Text("Select a command to customize")
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 500, minHeight: 620)
        }
        .frame(minWidth: 760, minHeight: 640)
    }

    private var sidebarContent: some View {
        List(selection: $viewModel.selectedItem) {
            // General Settings Item
            Section {
                NavigationLink(value: NavigationItem.general) {
                    Label("General Preferences", systemImage: "gearshape")
                        .font(.body)
                }
            }

            // Grouped Commands by Category
            ForEach(SnapCategory.allCases) { category in
                let actions = filteredActions(for: category)
                if !actions.isEmpty {
                    Section(header: Text(category.rawValue.uppercased()).font(.caption2.bold())) {
                        ForEach(actions) { action in
                            NavigationLink(value: NavigationItem.command(action)) {
                                HStack {
                                    Image(systemName: action.systemIcon)
                                        .frame(width: 18)
                                        .foregroundColor(.accentColor)
                                    Text(action.title)
                                    Spacer()
                                    let combo = settings.keyCombination(for: action)
                                    Text(combo.displayString)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search commands")
        .listStyle(.sidebar)
    }

    private func filteredActions(for category: SnapCategory) -> [SnapAction] {
        let categoryActions = SnapAction.allCases.filter { $0.category == category }
        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return categoryActions
        }
        return categoryActions.filter {
            $0.title.localizedCaseInsensitiveContains(viewModel.searchText) ||
            settings.keyCombination(for: $0).displayString.contains(viewModel.searchText)
        }
    }
}
