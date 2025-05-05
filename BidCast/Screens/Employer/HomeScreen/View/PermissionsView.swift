//
//  PermissionsView.swift
//  imperium
//
//  Created by JAM-E-221 on 25/01/25.
//

import SwiftUI

struct Permission: Identifiable {
    let id = UUID()
    let permission: String
    var isReadSelected: Bool
    var isWriteSelected: Bool
    var isDeleteSelected: Bool
}

class PermissionsViewModel: ObservableObject {
    @Published var permissions: [Permission]

    init(permissions: [Permission]) {
        self.permissions = permissions
    }
}

struct PermissionsRowView: View {
    @Binding var permission: Permission
    var onUpdate: (([[String: Any]]) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(permission.permission)
                .font(.custom(nunitoBold, fixedSize: 17))
                .bold()

            HStack(spacing: 60) {
                Toggle(isOn: Binding(
                    get: { permission.isReadSelected },
                    set: { newValue in
                        permission.isReadSelected = newValue
                        triggerUpdate()
                    }
                )) {
                    Text("Read Only")
                        .font(.custom(nunitoRegular, fixedSize: 15))
                }
                .toggleStyle(CheckboxToggleStyle())

                Toggle(isOn: Binding(
                    get: { permission.isWriteSelected },
                    set: { newValue in
                        permission.isWriteSelected = newValue
                        triggerUpdate()
                    }
                )) {
                    Text("Create")
                        .font(.custom(nunitoRegular, fixedSize: 15))
                }
                .toggleStyle(CheckboxToggleStyle())

                Toggle(isOn: Binding(
                    get: { permission.isDeleteSelected },
                    set: { newValue in
                        permission.isDeleteSelected = newValue
                        triggerUpdate()
                    }
                )) {
                    Text("Delete")
                        .font(.custom(nunitoRegular, fixedSize: 15))
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            .padding(.bottom, 8)

            Divider()
        }
        .padding(.vertical, 4)
    }
    

    
    

    private func triggerUpdate() {
        // Simulate a live update callback
        let permissionsArray = [
            [
                "permission": permission.permission,
                "read": permission.isReadSelected,
                "write": permission.isWriteSelected,
                "delete": permission.isDeleteSelected
            ]
        ]
        onUpdate?(permissionsArray)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .black : .gray)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PermissionsView: View {
    @ObservedObject var viewModel: PermissionsViewModel
    var onOptionSelected: (([[String: Any]]) -> Void)?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach($viewModel.permissions) { $permission in
                        PermissionsRowView(permission: $permission) { updatedPermissions in
                            onOptionSelected?(getFullPermissions())
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func getFullPermissions() -> [[String: Any]] {
        viewModel.permissions.map { permission in
            [
                "permission": permission.permission,
                "read": permission.isReadSelected,
                "write": permission.isWriteSelected,
                "delete": permission.isDeleteSelected
            ]
        }
    }
}

//#Preview {
//    PermissionsView()
//}
