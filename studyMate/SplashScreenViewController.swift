import UIKit

/// An elegant animated splash screen for StudyMate AI
class SplashScreenViewController: UIViewController {

    // MARK: - Callbacks
    var onAnimationCompleted: (() -> Void)?

    // MARK: - UI Components
    private let backgroundGradientView = UIView()
    private let centerContainer = UIView()
    private let iconShadowContainer = UIView()
    private let iconImageView = UIImageView()
    private let glowRingView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pillTagView = UIView()
    private let pillLabel = UILabel()

    private var hasDispatchedCompletion = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapToSkip()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startEntranceAnimations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientView.frame = view.bounds
        backgroundGradientView.applyGradientBackground(
            colors: [
                UIColor(red: 0.07, green: 0.07, blue: 0.16, alpha: 1.0).cgColor,
                UIColor(red: 0.12, green: 0.08, blue: 0.28, alpha: 1.0).cgColor,
                UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0).cgColor
            ],
            startPoint: CGPoint(x: 0.2, y: 0.0),
            endPoint: CGPoint(x: 0.8, y: 1.0)
        )
        glowRingView.layer.cornerRadius = glowRingView.bounds.width / 2
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.16, alpha: 1.0)

        // Background Gradient
        backgroundGradientView.isUserInteractionEnabled = false
        view.addSubview(backgroundGradientView)

        // Center Container
        centerContainer.translatesAutoresizingMaskIntoConstraints = false
        centerContainer.alpha = 0
        centerContainer.transform = CGAffineTransform(scaleX: 0.68, y: 0.68)
        view.addSubview(centerContainer)

        // Pulsing Glow Ring behind icon
        glowRingView.translatesAutoresizingMaskIntoConstraints = false
        glowRingView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.25)
        glowRingView.layer.masksToBounds = false
        centerContainer.addSubview(glowRingView)

        // Icon Container with 3D drop glow
        iconShadowContainer.translatesAutoresizingMaskIntoConstraints = false
        iconShadowContainer.backgroundColor = .clear
        iconShadowContainer.layer.shadowColor = UIColor.systemPurple.cgColor
        iconShadowContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        iconShadowContainer.layer.shadowOpacity = 0.55
        iconShadowContainer.layer.shadowRadius = 24
        centerContainer.addSubview(iconShadowContainer)

        // Icon Image
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 24
        iconImageView.clipsToBounds = true
        iconImageView.layer.borderWidth = 1.5
        iconImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        // Load generated app icon or fallback to SF Symbol
        if let iconImage = UIImage(named: "AppLogo") ?? UIImage(named: "AppIcon-180") ?? UIImage(named: "AppIcon") {
            iconImageView.image = iconImage
        } else {
            iconImageView.image = UIImage(systemName: "graduationcap.fill")
            iconImageView.tintColor = .white
            iconImageView.backgroundColor = UIColor.systemPurple
            iconImageView.contentMode = .center
        }
        iconShadowContainer.addSubview(iconImageView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "StudyMate AI"
        titleLabel.font = .systemFont(ofSize: 34, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.systemPurple.cgColor
        titleLabel.layer.shadowOpacity = 0.6
        titleLabel.layer.shadowRadius = 12
        titleLabel.layer.shadowOffset = .zero

        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Master Every Subject with AI Tutoring"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        subtitleLabel.textAlignment = .center

        // Pill Tag: "Powered by Gemini ✨"
        pillTagView.translatesAutoresizingMaskIntoConstraints = false
        pillTagView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        pillTagView.layer.cornerRadius = 14
        pillTagView.layer.borderWidth = 1.0
        pillTagView.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.4).cgColor

        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pillLabel.text = "✨ Powered by Google Gemini"
        pillLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        pillLabel.textColor = UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0)
        pillTagView.addSubview(pillLabel)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(pillTagView)

        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 16)

        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 16)

        pillTagView.alpha = 0
        pillTagView.transform = CGAffineTransform(translationX: 0, y: 16)

        // Constraints
        NSLayoutConstraint.activate([
            centerContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            centerContainer.widthAnchor.constraint(equalToConstant: 120),
            centerContainer.heightAnchor.constraint(equalToConstant: 120),

            glowRingView.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
            glowRingView.centerYAnchor.constraint(equalTo: centerContainer.centerYAnchor),
            glowRingView.widthAnchor.constraint(equalToConstant: 140),
            glowRingView.heightAnchor.constraint(equalToConstant: 140),

            iconShadowContainer.topAnchor.constraint(equalTo: centerContainer.topAnchor),
            iconShadowContainer.leadingAnchor.constraint(equalTo: centerContainer.leadingAnchor),
            iconShadowContainer.trailingAnchor.constraint(equalTo: centerContainer.trailingAnchor),
            iconShadowContainer.bottomAnchor.constraint(equalTo: centerContainer.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: iconShadowContainer.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: iconShadowContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconShadowContainer.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconShadowContainer.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: centerContainer.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            pillTagView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pillTagView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            pillTagView.heightAnchor.constraint(equalToConstant: 28),

            pillLabel.leadingAnchor.constraint(equalTo: pillTagView.leadingAnchor, constant: 14),
            pillLabel.trailingAnchor.constraint(equalTo: pillTagView.trailingAnchor, constant: -14),
            pillLabel.centerYAnchor.constraint(equalTo: pillTagView.centerYAnchor)
        ])
    }

    private func setupTapToSkip() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        finishAndDismiss()
    }

    // MARK: - Animations
    private func startEntranceAnimations() {
        // 1. Spring scale-in for icon
        UIView.animate(
            withDuration: 0.85,
            delay: 0.05,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: {
                self.centerContainer.alpha = 1.0
                self.centerContainer.transform = .identity
            }
        )

        // 2. Pulse animation for glow ring
        UIView.animate(
            withDuration: 1.2,
            delay: 0.2,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.glowRingView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                self.glowRingView.alpha = 0.55
            }
        )

        // 3. Fade and slide-up for Title
        UIView.animate(
            withDuration: 0.65,
            delay: 0.35,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.titleLabel.alpha = 1.0
                self.titleLabel.transform = .identity
            }
        )

        // 4. Fade and slide-up for Subtitle
        UIView.animate(
            withDuration: 0.65,
            delay: 0.5,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.subtitleLabel.alpha = 1.0
                self.subtitleLabel.transform = .identity
            }
        )

        // 5. Fade and slide-up for Pill Tag
        UIView.animate(
            withDuration: 0.65,
            delay: 0.65,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.pillTagView.alpha = 1.0
                self.pillTagView.transform = .identity
            },
            completion: { _ in
                // Automatically finish after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                    self?.finishAndDismiss()
                }
            }
        )
    }

    private func finishAndDismiss() {
        guard !hasDispatchedCompletion else { return }
        hasDispatchedCompletion = true
        HapticHelper.lightImpact()

        if Thread.isMainThread {
            self.onAnimationCompleted?()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onAnimationCompleted?()
            }
        }
    }
}
