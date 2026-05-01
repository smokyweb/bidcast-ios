//
//  SignUpTodayCell.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//
//  VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): mirrors Android
//  fragment_login.xml's bottom block — a "Privacy Policy | Terms of Service"
//  underlined link row above a centered "New User? Create Account" prompt.
//

import UIKit

class SignUpTodayCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var newToRiseShine: UIButton!
    @IBOutlet var signUpBtn: UIButton!

    //MARK: Programmatic privacy/terms row (added in awakeFromNib).
    private let privacyTermsStack = UIStackView()
    private let privacyButton = UIButton(type: .system)
    private let pipeLabel = UILabel()
    private let termsButton = UIButton(type: .system)

    //MARK: properties.
    static let identifier = "SignUpTodayCell"
    var didTapSignUpClosure : (UIButton) -> () = {_ in}
    var didTapPrivacyClosure: (UIButton) -> () = {_ in}
    var didTapTermsClosure: (UIButton) -> () = {_ in}

    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.setupPrivacyTermsRow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: IBAction.
    @IBAction func didTapSignUP(_ sender: UIButton) {
        self.didTapSignUpClosure(sender)
    }

    @objc private func didTapPrivacy(_ sender: UIButton) {
        self.didTapPrivacyClosure(sender)
    }

    @objc private func didTapTerms(_ sender: UIButton) {
        self.didTapTermsClosure(sender)
    }

    //MARK: setupUI
    func setupUI(){
        self.newToRiseShine.titleLabel?.font = JostFont.defaultSemiBold(size: 14).value
        self.signUpBtn.titleLabel?.font = JostFont.defaultBold(size: 14).value
        // VISUAL PARITY: Android renders the "Create Account" link as plain
        // bold black, not coral/blue. Force black here in case the xib's
        // tintColor cascade pulls it back to secondary.
        self.signUpBtn.setTitleColor(AppColor.darkGray, for: .normal)
        self.newToRiseShine.setTitleColor(AppColor.mediumDarkGray, for: .normal)
        selectionStyle = .none
    }

    /// VISUAL PARITY: add the Android-style "Privacy Policy | Terms of Service"
    /// underlined link row near the top of the cell, above the centered
    /// "New User? Create Account" stack that was already in the xib.
    private func setupPrivacyTermsRow() {
        privacyTermsStack.translatesAutoresizingMaskIntoConstraints = false
        privacyTermsStack.axis = .horizontal
        privacyTermsStack.alignment = .center
        privacyTermsStack.spacing = 6
        privacyTermsStack.distribution = .fill

        // HOTFIX 2026-05-01 (MC cmomwykts00233r1hcw317di3): JostFont.value
        // returns UIFont? — if the custom Jost font isn't registered the
        // value is nil, which bridges to NSNull in the attribute dict and
        // crashes -[NSCoreTypesetter ...] with `-[NSNull pointSize]`.
        // Build defensively: only add the font key if we have a real font,
        // otherwise fall back to system font.
        let linkFont: UIFont = JostFont.defaultRegular(size: 13).value
            ?? UIFont.systemFont(ofSize: 13)
        let underline: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: linkFont,
            .foregroundColor: AppColor.darkGray ?? UIColor.darkGray
        ]
        privacyButton.setAttributedTitle(
            NSAttributedString(string: "Privacy Policy", attributes: underline),
            for: .normal
        )
        termsButton.setAttributedTitle(
            NSAttributedString(string: "Terms of Service", attributes: underline),
            for: .normal
        )
        privacyButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms(_:)), for: .touchUpInside)

        pipeLabel.text = "|"
        pipeLabel.font = linkFont
        pipeLabel.textColor = AppColor.mediumDarkGray
        pipeLabel.setContentHuggingPriority(.required, for: .horizontal)
        pipeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        privacyTermsStack.addArrangedSubview(privacyButton)
        privacyTermsStack.addArrangedSubview(pipeLabel)
        privacyTermsStack.addArrangedSubview(termsButton)

        contentView.addSubview(privacyTermsStack)
        NSLayoutConstraint.activate([
            privacyTermsStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            privacyTermsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        ])
    }
}
