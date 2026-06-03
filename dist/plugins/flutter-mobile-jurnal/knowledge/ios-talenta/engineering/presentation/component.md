---
platform: ios
project: ios-talenta
discipline: engineering
topic: presentation
pattern: component
---

## Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

## Component

Reusable cell or view — UIModel pattern, no ViewModel awareness. Receives a plain `UIModel` struct via `configure(with:)`.

Path: `Talenta/Module/[Module]/Presentation/View/Cell/[Feature]TableViewCell.swift`

```swift
final class [Feature]TableViewCell: UITableViewCell {
    static let reuseIdentifier = "[Feature]TableViewCell"

    struct UIModel {
        let title: String
        let subtitle: String
    }

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        titleLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview().inset(MpSpacing.medium) }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(MpSpacing.small)
            $0.leading.trailing.bottom.equalToSuperview().inset(MpSpacing.medium)
        }
    }

    func configure(with model: UIModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
}
```

Rules:
- `UIModel` is a nested struct — pure display data, no business logic
- `prepareForReuse()` must clear all displayed values (and reset `disposeBag` if RxSwift is used)
- SnapKit for layout — no storyboards
- Use MekariPixel tokens for spacing/colors
- Mark class `final`
