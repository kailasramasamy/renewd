import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private let appGroupId = "group.com.quartex.renewd"
    private let sharedKey = "ShareKey"

    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Toast container
        let toast = UIView()
        toast.backgroundColor = UIColor.systemBackground
        toast.layer.cornerRadius = 16
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)

        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.tintColor = .systemGreen
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Saved to Renewd"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.text = "Open Renewd to start AI analysis"
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .secondaryLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        toast.addSubview(icon)
        toast.addSubview(titleLabel)
        toast.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toast.widthAnchor.constraint(equalToConstant: 280),

            icon.topAnchor.constraint(equalTo: toast.topAnchor, constant: 24),
            icon.centerXAnchor.constraint(equalTo: toast.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: toast.centerXAnchor),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            messageLabel.centerXAnchor.constraint(equalTo: toast.centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -24),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleSharedItems()
    }

    private func handleSharedItems() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }

        let group = DispatchGroup()
        var sharedItems: [[String: String]] = []

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                group.enter()
                if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { [weak self] data, _ in
                        defer { group.leave() }
                        if let url = data as? URL, let path = self?.copyToSharedContainer(url) {
                            sharedItems.append(["path": path, "type": "file"])
                        }
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] data, _ in
                        defer { group.leave() }
                        if let url = data as? URL, let path = self?.copyToSharedContainer(url) {
                            sharedItems.append(["path": path, "type": "file"])
                        }
                    }
                } else {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            if !sharedItems.isEmpty {
                let userDefaults = UserDefaults(suiteName: self?.appGroupId)
                let jsonData = try? JSONSerialization.data(withJSONObject: sharedItems)
                if let jsonData = jsonData {
                    userDefaults?.set(String(data: jsonData, encoding: .utf8), forKey: self?.sharedKey ?? "")
                    userDefaults?.synchronize()
                }
                // Open the main app, then dismiss
                self?.openContainingApp()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.completeRequest()
                }
            } else {
                self?.messageLabel.text = "Unsupported file type"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.completeRequest()
                }
            }
        }
    }

    private func copyToSharedContainer(_ url: URL) -> String? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else { return nil }

        let fileName = url.lastPathComponent
        let destURL = containerURL.appendingPathComponent(fileName)

        try? FileManager.default.removeItem(at: destURL)
        do {
            try FileManager.default.copyItem(at: url, to: destURL)
            return destURL.path
        } catch {
            return nil
        }
    }

    private func openContainingApp() {
        guard let url = URL(string: "renewd://share") else { return }
        // Walk the responder chain to reach UIApplication.openURL
        var responder: UIResponder? = self
        while let r = responder {
            if r.responds(to: #selector(openURL(_:))) {
                r.perform(#selector(openURL(_:)), with: url)
                return
            }
            responder = r.next
        }
    }

    @objc private func openURL(_ url: URL) {
        // Placeholder — never called directly; resolved via responder chain
    }

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
