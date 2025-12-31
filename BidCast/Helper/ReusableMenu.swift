//
//  ReusableMenu.swift
//  BidCast
//
//  Created by JamTech on 31/12/25.

import SwiftUI

// MARK: - Menu Option Model
struct MenuOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let iconColor: Color
    let role: ButtonRole?
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        iconColor: Color = .primary,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.role = role
        self.action = action
    }
}

// MARK: - Reusable Menu View
struct ReusableMenu: View {
    let options: [MenuOption]
    let style: MenuStyle
    
    enum MenuStyle {
        case vertical
        case horizontal
        case dots
        case dotsVertical
        
        var icon: String {
            switch self {
            case .vertical:
                return "ellipsis"
            case .horizontal:
                return "ellipsis"
            case .dots:
                return "ellipsis.circle"
            case .dotsVertical:
                return "ellipsis"
            }
        }
        
        var rotation: Double {
            switch self {
            case .vertical, .dotsVertical:
                return 90
            default:
                return 0
            }
        }
    }
    
    init(options: [MenuOption], style: MenuStyle = .dotsVertical) {
        self.options = options
        self.style = style
    }
    
    var body: some View {
        Menu {
            ForEach(options) { option in
                if let role = option.role {
                    Button(role: role, action: option.action) {
                        Label(option.title, systemImage: option.icon)
                    }
                } else {
                    Button(action: option.action) {
                        Label(option.title, systemImage: option.icon)
                    }
                }
            }
        } label: {
            menuLabel
        }
    }
    
    private var menuLabel: some View {
        Image(systemName: style.icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.gray)
            .frame(width: 32, height: 32)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .rotationEffect(.degrees(style.rotation))
    }
}


//
//// MARK: - Usage Examples
//
//// Example 1: Product Card Menu
//struct ProductCardView: View {
//    let product: ProductDataModel1
//    
//    // Define menu options as an array
//    private var menuOptions: [MenuOption] {
//        [
//            MenuOption(
//                icon: "pencil",
//                title: "Edit",
//                iconColor: .blue
//            ) {
//                handleEdit()
//            },
//            
//            MenuOption(
//                icon: product.isActive ? "pause.circle" : "play.circle",
//                title: product.isActive ? "Deactivate" : "Activate",
//                iconColor: product.isActive ? .orange : .green
//            ) {
//                handleActivation()
//            },
//            
//            MenuOption(
//                icon: "trash",
//                title: "Delete",
//                iconColor: .red,
//                role: .destructive
//            ) {
//                handleDelete()
//            }
//        ]
//    }
//    
//    var body: some View {
//        HStack {
//            Text(product.title ?? "Product")
//            
//            Spacer()
//            
//            // Simple usage - just pass the array!
//            ReusableMenu(options: menuOptions)
//        }
//        .padding()
//    }
//    
//    private func handleEdit() {
//        print("Edit tapped")
//    }
//    
//    private func handleActivation() {
//        print("Activation toggled")
//    }
//    
//    private func handleDelete() {
//        print("Delete tapped")
//    }
//}
//
//// Example 2: Dynamic Menu Based on State
//struct OrderCardView: View {
//    let order: OrderModel
//    
//    private var menuOptions: [MenuOption] {
//        var options: [MenuOption] = []
//        
//        // View Details (always available)
//        options.append(
//            MenuOption(
//                icon: "eye",
//                title: "View Details",
//                iconColor: .blue
//            ) {
//                viewDetails()
//            }
//        )
//        
//        // Cancel (only for pending orders)
//        if order.status == "pending" {
//            options.append(
//                MenuOption(
//                    icon: "xmark.circle",
//                    title: "Cancel Order",
//                    iconColor: .red,
//                    role: .destructive
//                ) {
//                    cancelOrder()
//                }
//            )
//        }
//        
//        // Track (only for shipped orders)
//        if order.status == "shipped" {
//            options.append(
//                MenuOption(
//                    icon: "location",
//                    title: "Track Package",
//                    iconColor: .green
//                ) {
//                    trackPackage()
//                }
//            )
//        }
//        
//        // Reorder (for completed orders)
//        if order.status == "completed" {
//            options.append(
//                MenuOption(
//                    icon: "arrow.clockwise",
//                    title: "Reorder",
//                    iconColor: .blue
//                ) {
//                    reorder()
//                }
//            )
//        }
//        
//        // Share (always available)
//        options.append(
//            MenuOption(
//                icon: "square.and.arrow.up",
//                title: "Share",
//                iconColor: .gray
//            ) {
//                shareOrder()
//            }
//        )
//        
//        return options
//    }
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("Order #\(order.id)")
//                Text(order.status)
//                    .font(.caption)
//            }
//            
//            Spacer()
//            
//            ReusableMenu(
//                options: menuOptions,
//                style: .dotsVertical
//            )
//        }
//        .padding()
//    }
//    
//    private func viewDetails() { }
//    private func cancelOrder() { }
//    private func trackPackage() { }
//    private func reorder() { }
//    private func shareOrder() { }
//}
//
//// Example 3: Custom Label Menu
//struct ShowCardView: View {
//    let show: HomeModel
//    
//    private var menuOptions: [MenuOption] {
//        [
//            MenuOption(
//                icon: "pencil",
//                title: "Edit Show",
//                iconColor: .blue
//            ) {
//                editShow()
//            },
//            
//            MenuOption(
//                icon: "calendar",
//                title: "Reschedule",
//                iconColor: .orange
//            ) {
//                reschedule()
//            },
//            
//            MenuOption(
//                icon: "person.2",
//                title: "Share with Team",
//                iconColor: .green
//            ) {
//                share()
//            },
//            
//            MenuOption(
//                icon: "trash",
//                title: "Cancel Show",
//                iconColor: .red,
//                role: .destructive
//            ) {
//                cancelShow()
//            }
//        ]
//    }
//    
//    var body: some View {
//        HStack {
//            Text(show.title ?? "Show")
//            
//            Spacer()
//            
//            // Custom label
//            CustomReusableMenu(options: menuOptions) {
//                HStack {
//                    Image(systemName: "ellipsis.circle.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding()
//    }
//    
//    private func editShow() { }
//    private func reschedule() { }
//    private func share() { }
//    private func cancelShow() { }
//}
//
//// Example 4: Different Menu Styles
//struct MenuStylesExampleView: View {
//    private let sampleOptions = [
//        MenuOption(icon: "pencil", title: "Edit", iconColor: .blue) { },
//        MenuOption(icon: "trash", title: "Delete", iconColor: .red, role: .destructive) { }
//    ]
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Vertical dots (default)
//            ReusableMenu(options: sampleOptions, style: .dotsVertical)
//            
//            // Horizontal dots
//            ReusableMenu(options: sampleOptions, style: .horizontal)
//            
//            // Dots with circle
//            ReusableMenu(options: sampleOptions, style: .dots)
//        }
//    }
//}
//
//// Example 5: Inventory Screen Menu (Your Original Use Case)
//struct InventoryProductCard: View {
//    let product: ProductDataModel1
//    @Binding var navigateToEdit: Bool
//    @Binding var showDeleteAlert: Bool
//    
//    private var menuOptions: [MenuOption] {
//        [
//            MenuOption(
//                icon: "pencil",
//                title: "Edit",
//                iconColor: .blue
//            ) {
//                navigateToEdit = true
//            },
//            
//            MenuOption(
//                icon: product.isActive == true ? "pause.circle" : "play.circle",
//                title: product.isActive == true ? "Deactivate" : "Activate",
//                iconColor: product.isActive == true ? .orange : .green
//            ) {
//                toggleActivation()
//            },
//            
//            MenuOption(
//                icon: "trash",
//                title: "Delete",
//                iconColor: .red,
//                role: .destructive
//            ) {
//                showDeleteAlert = true
//            }
//        ]
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                // Product image
//                AsyncImage(url: URL(string: product.images?.first ?? "")) { image in
//                    image.resizable()
//                } placeholder: {
//                    Color.gray
//                }
//                .frame(width: 60, height: 60)
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                
//                // Product info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(product.title ?? "")
//                        .font(.custom(poppinsSemiBold, size: 14))
//                    
//                    Text("$\(product.pricing ?? "0")")
//                        .font(.custom(poppinsBold, size: 16))
//                }
//                
//                Spacer()
//                
//                // Menu
//                ReusableMenu(options: menuOptions)
//            }
//            .padding()
//        }
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//    
//    private func toggleActivation() {
//        // Handle activation toggle
//    }
//}
//
//// Example 6: Advanced - Sectioned Menu
//struct SectionedMenuExample: View {
//    private var menuOptions: [MenuOption] {
//        [
//            // Actions Section
//            MenuOption(
//                icon: "pencil",
//                title: "Edit",
//                iconColor: .blue
//            ) {
//                print("Edit")
//            },
//            
//            MenuOption(
//                icon: "square.and.arrow.up",
//                title: "Share",
//                iconColor: .blue
//            ) {
//                print("Share")
//            },
//            
//            MenuOption(
//                icon: "square.and.arrow.down",
//                title: "Download",
//                iconColor: .blue
//            ) {
//                print("Download")
//            },
//            
//            // Danger Section
//            MenuOption(
//                icon: "trash",
//                title: "Delete",
//                iconColor: .red,
//                role: .destructive
//            ) {
//                print("Delete")
//            }
//        ]
//    }
//    
//    var body: some View {
//        ReusableMenu(options: menuOptions)
//    }
//}
//
//// MARK: - Helper Extension for Common Menu Patterns
//extension View {
//    /// Adds a standard CRUD menu to any view
//    func crudMenu(
//        onEdit: @escaping () -> Void,
//        onDelete: @escaping () -> Void,
//        onActivate: (() -> Void)? = nil,
//        isActive: Bool = false
//    ) -> some View {
//        var options = [
//            MenuOption(
//                icon: "pencil",
//                title: "Edit",
//                iconColor: .blue,
//                action: onEdit
//            )
//        ]
//        
//        if let onActivate = onActivate {
//            options.append(
//                MenuOption(
//                    icon: isActive ? "pause.circle" : "play.circle",
//                    title: isActive ? "Deactivate" : "Activate",
//                    iconColor: isActive ? .orange : .green,
//                    action: onActivate
//                )
//            )
//        }
//        
//        options.append(
//            MenuOption(
//                icon: "trash",
//                title: "Delete",
//                iconColor: .red,
//                role: .destructive,
//                action: onDelete
//            )
//        )
//        
//        return self.overlay(
//            ReusableMenu(options: options),
//            alignment: .topTrailing
//        )
//    }
//}
//
//// Example 7: Using the Helper Extension
//struct ProductRowSimple: View {
//    let product: ProductDataModel1
//    @State private var showDeleteAlert = false
//    
//    var body: some View {
//        HStack {
//            Text(product.title ?? "")
//            Spacer()
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .crudMenu(
//            onEdit: { editProduct() },
//            onDelete: { showDeleteAlert = true },
//            onActivate: { toggleActivation() },
//            isActive: product.isActive ?? false
//        )
//    }
//    
//    private func editProduct() { }
//    private func toggleActivation() { }
//}
//
//// MARK: - Preview
//struct ReusableMenuExample_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            Text("Different Menu Styles")
//                .font(.headline)
//            
//            MenuStylesExampleView()
//        }
//        .padding()
//    }
//}
//
//// MARK: - Mock Models for Examples
//struct OrderModel {
//    let id: String
//    let status: String
//}
