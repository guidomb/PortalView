//
//  UIKit.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/13/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import UIKit
import MapKit

public let defaultFont: Font = {
    let font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
    return font
}()

public let defaultButtonFontSize = UInt(UIFont.buttonFontSize)

internal typealias AfterLayoutTask = () -> ()

internal struct Render<MessageType> {
    
    let view: UIView
    let mailbox: Mailbox<MessageType>?
    let afterLayout: AfterLayoutTask?
    
    init(view: UIView, mailbox: Mailbox<MessageType>? = .none, executeAfterLayout afterLayout: AfterLayoutTask? = .none) {
        self.view = view
        self.afterLayout = afterLayout
        self.mailbox = mailbox
    }
    
}

internal protocol UIKitRenderer {
    
    associatedtype MessageType
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType>
    
}

internal final class ObjCMessageDispatcher<MessageType>: NSObject {
    
    internal let mailbox: Mailbox<MessageType>
    internal let message: MessageType
    
    init(message: MessageType, mailbox: Mailbox<MessageType> = Mailbox()) {
        self.mailbox = mailbox
        self.message = message
    }
    
    @objc
    internal func dispatch() {
        mailbox.dispatch(message: message)
    }
    
}

extension Component: UIKitRenderer {
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        switch self {
            
        case .button(let properties, let style, let layout):
            return ButtonRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .label(let properties, let style, let layout):
            return LabelRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .mapView(let properties, let style, let layout):
            return MapViewRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .imageView(let image, let style, let layout):
            return ImageViewRenderer(image: image, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .container(let children, let style, let layout):
            return ContainerRenderer(children: children, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .table(let properties, let style, let layout):
            return TableRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        }
    }
    
}

internal protocol UIImageConvertible {
    
    var asUIImage: UIImage { get }
    
}

public typealias Image = UIImageContainer

public struct UIImageContainer: ImageType, UIImageConvertible {
    
    public static func loadImage(named imageName: String, from bundle: Bundle = .main) -> UIImageContainer? {
        return UIImage(named: imageName, in: bundle, compatibleWith: .none).map(UIImageContainer.init)
    }
    
    public var size: Size {
        return Size(width: UInt(image.size.width), height: UInt(image.size.height))
    }
    
    var asUIImage: UIImage {
        return image
    }
    
    private let image: UIImage
    
    internal init(image: UIImage) {
        self.image = image
    }
    
}

fileprivate struct LabelRenderer<MessageType>: UIKitRenderer {
    
    let properties: LabelProperties
    let style: StyleSheet<LabelStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let label = UILabel()
        label.text = properties.text
        
        label.apply(style: style.base)
        label.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: label)
        
        return Render(view: label) {
            if let textAfterLayout = self.properties.textAfterLayout, let size = label.maximumFontSizeForWidth() {
                label.text = textAfterLayout
                label.font = label.font.withSize(size)
                label.adjustsFontSizeToFitWidth = false
                label.minimumScaleFactor = 0.0
            }
        }
    }
    
}

fileprivate struct ImageViewRenderer<MessageType>: UIKitRenderer {
    
    let image: Image
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let imageView = UIImageView(image: image.asUIImage)
        
        imageView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: imageView)
        
        return Render(view: imageView)
    }
    
}

fileprivate struct ButtonRenderer<MessageType>: UIKitRenderer {
    
    let properties: ButtonProperties<MessageType>
    let style: StyleSheet<ButtonStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let button = UIButton()
        
        properties.text |> { button.setTitle($0, for: .normal) }
        properties.icon |> { button.setImage($0.asUIImage, for: .normal) }
        button.isSelected = properties.isActive
        
        button.apply(style: style.base)
        button.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: button)
        
        button.unregisterDispatchers()
        button.removeTarget(.none, action: .none, for: .touchUpInside)
        let mailbox = button.bindMessageDispatcher { mailbox in
            properties.onTap |> { _ = button.dispatch(message: $0, for: .touchUpInside, with: mailbox) }
        }
        
        return Render(view: button, mailbox: mailbox)
    }
    
}

fileprivate struct MapViewRenderer<MessageType>: UIKitRenderer {
    
    let properties: MapProperties
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let mapView = PortalMapView(placemarks: properties.placemarks)
        
        mapView.isZoomEnabled = properties.isZoomEnabled
        if let center = properties.center {
            let span = MKCoordinateSpanMake(properties.zoomLevel, properties.zoomLevel)
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                span: span
            )
            mapView.setRegion(region, animated: true)
        }
        mapView.isScrollEnabled = properties.isScrollEnabled
        
        mapView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: mapView)
        
        return Render(view: mapView)
    }
    
}

fileprivate struct ContainerRenderer<MessageType>: UIKitRenderer {
    
    let children: [Component<MessageType>]
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let view = UIView()
        view.managedByPortal = true
        
        var afterLayoutTasks: [AfterLayoutTask] = []
        let mailbox = Mailbox<MessageType>()
        for child in children {
            let renderResult = child.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            renderResult.view.managedByPortal = true
            view.addSubview(renderResult.view)
            renderResult.afterLayout    |> { afterLayoutTasks.append($0) }
            renderResult.mailbox        |> { $0.forward(to: mailbox) }
        }
        
        view.apply(style: self.style.base)
        layoutEngine.apply(layout: self.layout, to: view)
        
        return Render(view: view, mailbox: mailbox) {
            afterLayoutTasks.forEach { $0() }
        }
    }
    
}

fileprivate struct TableRenderer<MessageType>: UIKitRenderer {
    
    let properties: TableProperties<MessageType>
    let style: StyleSheet<TableStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let table = PortalTableView(items: properties.items, layoutEngine: layoutEngine)
        
        table.isDebugModeEnabled = isDebugModeEnabled
        table.showsVerticalScrollIndicator = properties.showsVerticalScrollIndicator
        table.showsHorizontalScrollIndicator = properties.showsHorizontalScrollIndicator

        
        table.apply(style: style.base)
        table.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: table)
        
        return Render(view: table, mailbox: table.mailbox)
    }
    
}

fileprivate struct NavigationBarTitleRenderer<MessageType> {
    
    let navigationBarTitle: NavigationBarTitle<MessageType>
    let navigationItem: UINavigationItem
    let navigationBarSize: CGSize
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Mailbox<MessageType>? {
        switch navigationBarTitle {
            
        case .text(let title):
            navigationItem.title = title
            return .none
            
        case .image(let image):
            navigationItem.titleView = UIImageView(image: image.asUIImage)
            return .none
            
        case .component(let titleComponent):
            let titleView = UIView(frame: CGRect(origin: .zero, size: navigationBarSize))
            navigationItem.titleView = titleView
            var renderer = UIKitComponentRenderer<MessageType>(containerView: titleView, layoutEngine: layoutEngine)
            renderer.isDebugModeEnabled = isDebugModeEnabled
            return renderer.render(component: titleComponent)
        }
        
    }
    
}


public struct UIKitComponentRenderer<MessageType>: Renderer {
    
    public var isDebugModeEnabled: Bool = false
    
    private let containerView: UIView
    private let layoutEngine: LayoutEngine
    
    public init(containerView: UIView, layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.containerView = containerView
        self.layoutEngine = layoutEngine
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        let renderResult = component.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        renderResult.view.managedByPortal = true
        layoutEngine.layout(view: renderResult.view, inside: containerView)
        renderResult.afterLayout?()
            
        if isDebugModeEnabled {
            renderResult.view.safeTraverse { $0.addDebugFrame() }
        }
        
        return renderResult.mailbox ?? Mailbox<MessageType>()
    }
    
}

public final class PortalViewController<MessageType, RendererType: Renderer>: UIViewController
    where RendererType.MessageType == MessageType, RendererType.MailboxType == Mailbox<MessageType> {
    
    public typealias RendererFactory = (UIView) -> RendererType
    
    public var component: Component<MessageType>
    public let mailbox = Mailbox<MessageType>()
    
    private let createRenderer: RendererFactory
    
    public init(component: Component<MessageType>, factory createRenderer: @escaping RendererFactory) {
        self.component = component
        self.createRenderer = createRenderer
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        render()
    }
    
    public func render() {
        // For some reason, probably related to Yoga, we need to create
        // a new view when updating a contained controller's view whos
        // parent is a navigation controller because if not the view
        // does not take into account the navigation bar in order
        // to sets its visible size.
        self.view = UIView(frame: calculateViewBounds())
        let renderer = createRenderer(view)
        let componentMailbox = renderer.render(component: component)
        componentMailbox.forward(to: mailbox)
    }
    
}

fileprivate extension PortalViewController {
    
    fileprivate var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    
    /// The bounds of the container view used to render the controller's component
    /// needs to be calcuated using this method because if the component is redenred
    /// on the viewDidLoad method for some reason UIKit reports the controller's view bounds
    /// to be equal to the screen's frame. Which does not take into account the status bar
    /// nor the navigation bar if the controllers is embeded inside a navigation controller.
    ///
    /// The funny thing is that if you ask for the controller's view bounds inside viewWillAppear
    /// the bounds are properly set but the component needs to be rendered cannot be rendered in
    /// viewWillAppear because some views, like UITableView have unexpected behavior.
    ///
    /// - Returns: The view bounds that should be used to render the component's view
    fileprivate func calculateViewBounds() -> CGRect {
        var bounds = view.bounds
        bounds.size.height -= statusBarHeight
        bounds.origin.x += statusBarHeight
        
        if let navBarBounds = navigationController?.navigationBar.bounds {
            bounds.size.height -= navBarBounds.size.height
            bounds.origin.x += navBarBounds.size.height
        }
        
        return bounds
    }
    
}

public final class PortalNavigationController: UINavigationController {
    
    private let statusBarStyle: UIStatusBarStyle
    
    init(rootViewController: UIViewController, statusBarStyle: UIStatusBarStyle = .`default`) {
        self.statusBarStyle = statusBarStyle
        super.init(nibName: nil, bundle: nil)
        pushViewController(rootViewController, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
}

public final class PortalTableViewCell<MessageType>: UITableViewCell {
    
    public let mailbox = Mailbox<MessageType>()
    public var component: Component<MessageType>? = .none
    public var isDebugModeEnabled: Bool {
        set {
            self.renderer?.isDebugModeEnabled = newValue
        }
        get {
            return self.renderer?.isDebugModeEnabled ?? false
        }
    }
    
    private var renderer: UIKitComponentRenderer<MessageType>? = .none
    
    public init(reuseIdentifier: String, layoutEngine: LayoutEngine) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.renderer = UIKitComponentRenderer(containerView: contentView, layoutEngine: layoutEngine)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render() {
        // TODO check if we need to do something about after layout hooks
        // TODO improve rendering performance by avoiding allocations.
        // Renderers should be able to reuse view objects instead of having
        // to allocate new ones if possible.
        if let component = self.component, let componentMailbox = renderer?.render(component: component) {
            componentMailbox.forward(to: mailbox)
        }
    }

    
}

public final class PortalTableView<MessageType>: UITableView, UITableViewDataSource, UITableViewDelegate {

    public let mailbox = Mailbox<MessageType>()
    public var isDebugModeEnabled: Bool = false
    
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let items: [TableItemProperties<MessageType>]
    
    // Used to cache cell actual height after rendering table 
    // item component. Caching cell height is usefull when
    // cells have dynamic height.
    fileprivate var cellHeights: [CGFloat?]
    
    public init(items: [TableItemProperties<MessageType>], layoutEngine: LayoutEngine) {
        self.items = items
        self.layoutEngine = layoutEngine
        self.cellHeights = Array(repeating: .none, count: items.count)
        
        super.init(frame: .zero, style: .plain)
        
        self.dataSource = self
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cellRender = itemRender(at: indexPath)
        let cell = dequeueReusableCell(with: cellRender.typeIdentifier)
        cell.component = cellRender.component

        let componentHeight = cell.component?.layout.height
        if componentHeight?.value == .none && componentHeight?.maximum == .none {
            // TODO replace this with a logger
            print("WARNING: Table item component with identifier '\(cellRender.typeIdentifier)' does not specify layout height! You need to either set layout.height.value or layout.height.maximum")
        }
    
        // For some reason the first page loads its cells with smaller bounds.
        // This forces the cell to have the width of its parent view.
        if let width = self.superview?.bounds.width {
            let baseHeight = itemBaseHeight(at: indexPath)
            cell.bounds.size.width = width
            cell.bounds.size.height = baseHeight
            cell.contentView.bounds.size.width = width
            cell.contentView.bounds.size.height = baseHeight
        }
        
        cell.selectionStyle = item.onTap.map { _ in item.selectionStyle.asUITableViewCellSelectionStyle } ?? .none
        cell.isDebugModeEnabled = isDebugModeEnabled
        cell.render()
        
        // After rendering the cell, the parent view returned by rendering the
        // item component has the actual height calculated after applying layout. 
        // This height needs to be cached in order to be returned in the 
        // UITableViewCellDelegate's method tableView(_,heightForRowAt:)
        let actualCellHeight = cell.contentView.subviews[0].bounds.height
        cellHeights[indexPath.row] = actualCellHeight
        cell.bounds.size.height = actualCellHeight
        cell.contentView.bounds.size.height = actualCellHeight
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemBaseHeight(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onTap |> { mailbox.dispatch(message: $0) }
    }
    
}

fileprivate extension PortalTableView {
    
    fileprivate func dequeueReusableCell(with identifier: String) -> PortalTableViewCell<MessageType> {
        if let cell = dequeueReusableCell(withIdentifier: identifier) as? PortalTableViewCell<MessageType> {
            return cell
        } else {
            let cell = PortalTableViewCell<MessageType>(reuseIdentifier: identifier, layoutEngine: layoutEngine)
            cell.mailbox.forward(to: mailbox)
            return cell
        }
    }
    
    fileprivate func itemRender(at indexPath: IndexPath) -> TableItemRender<MessageType> {
        // TODO cache the result of calling renderer. Once the diff algorithm is implemented find a way to only
        // replace items that have changed.
        // IGListKit uses some library or algorithm to diff array. Maybe that can be used to make the array diff
        // more efficient.
        //
        // https://github.com/Instagram/IGListKit
        //
        // Check the video of the talk that presents IGListKit to find the array diff algorithm.
        // Also there is Dwifft which seems to be based in the same algorithm:
        //
        // https://github.com/jflinter/Dwifft
        //
        let item = items[indexPath.row]
        return item.renderer(item.height)
    }
    
    fileprivate func itemMaxHeight(at indexPath: IndexPath) -> CGFloat {
        return CGFloat(items[indexPath.row].height)
    }
    
    
    /// Returns the cached actual height for the item at the given `indexPath`.
    /// Actual heights are cached using the `cellHeights` instance variable and
    /// are calculated after rending the item component inside the table view cell.
    /// This is usefull when cells have dynamic height.
    ///
    /// - Parameter indexPath: The item's index path.
    /// - Returns: The cached actual item height.
    fileprivate func itemActualHeight(at indexPath: IndexPath) -> CGFloat? {
        return cellHeights[indexPath.row]
    }
    
    
    /// Returns the item's cached actual height if available. Otherwise it 
    /// returns the item's max height.
    ///
    /// - Parameter indexPath: The item's index path.
    /// - Returns: the item's cached actual height or its max height.
    fileprivate func itemBaseHeight(at indexPath: IndexPath) -> CGFloat {
        return itemActualHeight(at: indexPath) ?? itemMaxHeight(at: indexPath)
    }
    
}


public final class UIKitComponentManager<MessageType>: Presenter, Renderer {

    public var isDebugModeEnabled: Bool = false
    
    public let mailbox = Mailbox<MessageType>()
    
    fileprivate let layoutEngine: LayoutEngine
    
    fileprivate var window: WindowManager<MessageType, UIKitComponentRenderer<MessageType>>
    
    public init(window: UIWindow, layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.window = WindowManager(window: window)
        self.layoutEngine = layoutEngine
    }
    
    public func present(component rootComponent: RootComponent<MessageType>) {
        switch rootComponent {
            
        case .simple(let component):
            let rootController = controller(forComponent: component)
            rootController.mailbox.forward(to: mailbox)
            window.rootController = .single(rootController)
        
        case .withNavigationBar(let navigationBar, let component):
            present(component: component, with: navigationBar)
            
        default:
            assertionFailure("Case not implemented")
            
        }
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        switch window.rootController {
        case .empty:
            let rootController = controller(forComponent: component)
            window.rootController = .single(rootController)
            rootController.mailbox.forward(to: mailbox)
            return rootController.mailbox
        case .single(let controller):
            controller.component = component
            controller.render()
            controller.mailbox.forward(to: mailbox)
            return controller.mailbox
        case .navigationController(_, let topController):
            topController.component = component
            topController.render()
            topController.mailbox.forward(to: mailbox)
            return topController.mailbox
        }
    }

    
    
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func present(component: Component<MessageType>, with navigationBar: NavigationBar<MessageType>) {
        let navigationBarSize: CGSize
        let containedController = controller(forComponent: component)
        if case .navigationController(let navigationController, _) = window.rootController {
            navigationController.pushViewController(containedController, animated: true)
            navigationBarSize = navigationController.navigationBar.bounds.size
        } else {
            let navigationController = PortalNavigationController(
                rootViewController: containedController,
                statusBarStyle: navigationBar.style.component.statusBarStyle.asUIStatusBarStyle
            )
            navigationBarSize = navigationController.navigationBar.bounds.size
            window.rootController = .navigationController(navigationController, topController: containedController)
        }
        containedController.navigationController?.navigationBar.apply(style: navigationBar.style)
        containedController.mailbox.forward(to: mailbox)
        
        render(navigationBar: navigationBar, of: navigationBarSize, inside: containedController.navigationItem)
    }
    
    fileprivate func render(navigationBar: NavigationBar<MessageType>, of navigationBarSize: CGSize, inside navigationItem: UINavigationItem) {
        if navigationBar.properties.hideBackButtonTitle {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain,target: nil, action: nil)
        }
        render(navigationBarTitle: navigationBar.properties.title, of: navigationBarSize, inside: navigationItem)
    }
    
    fileprivate func render(navigationBarTitle: NavigationBarTitle<MessageType>, of navigationBarSize: CGSize, inside navigationItem: UINavigationItem) {
        let renderer = NavigationBarTitleRenderer(
            navigationBarTitle: navigationBarTitle,
            navigationItem: navigationItem,
            navigationBarSize: navigationBarSize
        )
        renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled) |> { $0.forward(to: mailbox) }
    }
 
    fileprivate func controller(forComponent component: Component<MessageType>) -> PortalViewController<MessageType, UIKitComponentRenderer<MessageType>> {
        return PortalViewController(component: component) {
            var renderer = UIKitComponentRenderer<MessageType>(containerView: $0, layoutEngine: self.layoutEngine)
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
    }
    
}

fileprivate enum RootController<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType, RendererType.MailboxType == Mailbox<MessageType> {
    
    case empty
    case navigationController(PortalNavigationController, topController: PortalViewController<MessageType, RendererType>)
    case single(PortalViewController<MessageType, RendererType>)
    
}

fileprivate struct WindowManager<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType, RendererType.MailboxType == Mailbox<MessageType> {
    
    fileprivate var rootController: RootController<MessageType, RendererType> {
        set {
            switch newValue {
            case .single(let controller):
                window.rootViewController = controller
            case .navigationController(let navigationController, _):
                window.rootViewController = navigationController
            case .empty:
                window.rootViewController = .none
            }
            _rootController = newValue
        }
        get {
            return _rootController
        }
    }
    
    private let window: UIWindow
    private var _rootController: RootController<MessageType, RendererType>
    
    init(window: UIWindow) {
        self.window = window
        self._rootController = .empty
        self.rootController = .empty
    }
    
}

extension TableItemSelectionStyle {
    
    internal var asUITableViewCellSelectionStyle: UITableViewCellSelectionStyle {
        switch self {
        case .none:
            return .none
        case .`default`:
            return .`default`
        case .blue:
            return .blue
        case .gray:
            return .gray
        }
    }
    
}

extension StatusBarStyle {
    
    internal var asUIStatusBarStyle: UIStatusBarStyle {
        switch self {
        case .`default`:
            return .`default`
        case .lightContent:
            return .`lightContent`
        }
    }
    
}

internal protocol UIColorConvertible {
    
    var asUIColor: UIColor { get }
    
}

extension Color: UIColorConvertible {
    
    var asUIColor: UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}

extension TextAligment {
    
    var asNSTextAligment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        }
    }
    
}

extension UIView {
    
    public func apply(style: BaseStyleSheet) {
        style.backgroundColor   |> { self.backgroundColor = $0.asUIColor }
        style.cornerRadius      |> { self.layer.cornerRadius = CGFloat($0) }
    }
    
}

extension UIButton {
    
    public func apply(style: ButtonStyleSheet) {
        self.setTitleColor(style.textColor.asUIColor, for: .normal)
        style.textFont.uiFont(withSize: style.textSize) |> { self.titleLabel?.font = $0 }
    }
    
}

extension UILabel {
    
    public func apply(style: LabelStyleSheet) {
        let size = CGFloat(style.textSize)
        style.textFont.uiFont(withSize: size)     |> { self.font = $0 }
        style.textColor                           |> { self.textColor = $0.asUIColor }
        self.textAlignment = style.textAligment.asNSTextAligment
        self.adjustsFontSizeToFitWidth = style.adjustToFitWidth
        self.numberOfLines = Int(style.numberOfLines)
        self.minimumScaleFactor = CGFloat(style.minimumScaleFactor)
    }
    
}

extension UINavigationBar {
    
    public func apply(style: StyleSheet<NavigationBarStyleSheet>) {
        self.barTintColor = style.base.backgroundColor.asUIColor
        self.tintColor = style.component.tintColor.asUIColor
        self.isTranslucent = style.component.isTranslucent
        var titleTextAttributes: [String : Any] = [
            NSForegroundColorAttributeName : style.component.titleTextColor.asUIColor,
        ]
        let font = style.component.titleTextFont
        let fontSize = style.component.titleTextSize
        font.uiFont(withSize: fontSize) |> { titleTextAttributes[NSFontAttributeName] = $0 }
        self.titleTextAttributes = titleTextAttributes
    }
    
}

extension UITableView {
    
    public func apply(style: TableStyleSheet) {
        self.separatorColor = style.separatorColor.asUIColor
    }
    
}

extension Font {
    
    fileprivate func uiFont(withSize size: CGFloat) -> UIFont? {
        return UIFont(name: self.name, size: size)
    }
    
    fileprivate func uiFont(withSize size: UInt) -> UIFont? {
        return uiFont(withSize: CGFloat(size))
    }
    
}

public extension Font {
    
    public func register(using bundle: Bundle = Bundle.main) -> Bool {
        guard let fontURL = bundle.url(forResource: self.name, withExtension: "ttf") else { return false }
        var error: Unmanaged<CFError>?
        return CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    }
    
}

fileprivate var managedByPortalAssociationKey = 0
fileprivate var messageDispatcherAssociationKey = 0

extension UIView {
    
    fileprivate func safeTraverse(visitor: @escaping (UIView) -> ()) {
        guard self.managedByPortal else { return }
        
        visitor(self)
        self.subviews.forEach { $0.safeTraverse(visitor: visitor) }
    }
    
    fileprivate var managedByPortal: Bool {
        set {
            objc_setAssociatedObject(self, &managedByPortalAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &managedByPortalAssociationKey) as? Bool ?? false
        }
    }
    
    fileprivate func register<MessageType>(dispatcher: ObjCMessageDispatcher<MessageType>) {
        let dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey) as? NSMutableArray ?? NSMutableArray()
        dispatchers.add(dispatcher)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func unregisterDispatchers() {
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func bindMessageDispatcher<MessageType>(binder: (Mailbox<MessageType>) -> ()) -> Mailbox<MessageType> {
        unregisterDispatchers()
        let mailbox = Mailbox<MessageType>()
        binder(mailbox)
        return mailbox
    }
    
}

extension UIButton {
    
    fileprivate func dispatch<MessageType>(message: MessageType, for event: UIControlEvents, with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        let dispatcher = ObjCMessageDispatcher(message: message, mailbox: mailbox)
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: #selector(ObjCMessageDispatcher<MessageType>.dispatch), for: event)
        return dispatcher.mailbox
    }
    
}

fileprivate enum AnimationKey: String {
    
    case rotation360 = "io.Portal.View.AnimationKey.360DegreeRotation"
    
}

extension UIView {
    
    fileprivate func addDebugFrame() {
        topBorder(thickness: 1.0, color: .red)
        bottomBorder(thickness: 1.0, color: .red)
        leftBorder(thickness: 1.0, color: .red)
        rightBorder(thickness: 1.0, color: .red)
        
    }
    
    fileprivate func topBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: superview!.bounds.width - 1.0, height: CGFloat(thickness)))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func bottomBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: 0, y: bounds.height, width: superview!.bounds.width - 1.0,
                                              height: CGFloat(thickness)))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func leftBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(thickness), height: bounds.height))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func rightBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: superview!.bounds.width - 1.0, y: 0, width: CGFloat(thickness),
                                              height: bounds.height))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = .none) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        
        if let delegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        layer.add(rotateAnimation, forKey: AnimationKey.rotation360.rawValue)
    }
    
}

extension String {
    
    func maximumFontSize(forWidth width: CGFloat, font: UIFont) -> CGFloat {
        let text = self as NSString
        let minimumBoundingRect = text.size(attributes: [NSFontAttributeName : font])
        return width * font.pointSize / minimumBoundingRect.width
    }
    
}

extension UILabel {
    
    fileprivate func maximumFontSizeForWidth() -> CGFloat? {
        guard let text = self.text else { return .none }
        return text.maximumFontSize(forWidth: self.frame.width, font: self.font)
    }
    
}

extension UIFont: Font {
    
    public var name: String {
        return self.fontName
    }
    
}
