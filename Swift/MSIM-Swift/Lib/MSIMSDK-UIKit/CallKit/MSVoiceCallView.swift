//
//  MSVoiceCallView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/28.
//

import UIKit
import MSIMSDK
import Kingfisher


protocol MSVoiceCallViewDelegate: NSObjectProtocol {
    
    func voice_cancelBtnDidClick()
    func voice_mickBtnDidClick()
    func voice_handFreeBtnDidClick()
    func voice_rejectBtnDidClick()
    func voice_acceptBtnDidClick()
    func voice_hangupBtnDidClick()
}

class MSVoiceCallView: UIView {

    weak var delegate: MSVoiceCallViewDelegate?
    
    lazy var bgIcon: UIImageView = {
        let bgIcon = UIImageView(frame: UIScreen.main.bounds)
        bgIcon.contentMode = .scaleAspectFill
        bgIcon.clipsToBounds = true
        bgIcon.isUserInteractionEnabled = true
        
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView.init(effect: effect)
        effectView.frame = bgIcon.bounds
        bgIcon.addSubview(effectView)
        return bgIcon
    }()

    lazy var avatarIcon: UIImageView = {
        let avatarIcon = UIImageView(frame: CGRect(x: UIScreen.width * 0.5 - 60, y: UIScreen.height * 0.5 - 100 - 60, width: 120, height: 120))
        avatarIcon.layer.cornerRadius = 4
        avatarIcon.layer.masksToBounds = true
        avatarIcon.contentMode = .scaleAspectFill
        return avatarIcon
    }()
    
    lazy var durationL: UILabel = {
        let durationL = UILabel(frame: CGRect(x: UIScreen.width * 0.5 - 50, y: avatarIcon.top - 50, width: 100, height: 20))
        durationL.textColor = .white
        durationL.font = .systemFont(ofSize: 16)
        durationL.textAlignment = .center
        return durationL
    }()
    
    lazy var nickNameL: UILabel = {
        let nickNameL = UILabel(frame: CGRect(x: UIScreen.width * 0.5 - 50, y: avatarIcon.bottom + 15, width: 100, height: 35))
        nickNameL.font = .systemFont(ofSize: 20)
        nickNameL.textColor = .white
        nickNameL.textAlignment = .center
        return nickNameL
    }()
    
    lazy var noticeL: UILabel = {
        let noticeL = UILabel(frame: CGRect(x: UIScreen.width * 0.5 - 100, y: nickNameL.bottom + 20, width: 200, height: 20))
        noticeL.font = .systemFont(ofSize: 14)
        noticeL.textColor = .white
        noticeL.textAlignment = .center
        return noticeL
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(Bundle.bf_localizedString(key: "Cancel"), for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 12)
        cancelBtn.setImage(UIImage.bf_imageNamed(name: "ic_hangup"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClick), for: .touchUpInside)
        cancelBtn.frame = CGRect(x: UIScreen.width * 0.5 - 42, y: UIScreen.height - UIScreen.safeAreaBottomHeight - 30 - 114, width: 84, height: 114)
        return cancelBtn
    }()
    
    lazy var hangupBtn: UIButton = {
        let hangupBtn = UIButton(type: .custom)
        hangupBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallCancel"), for: .normal)
        hangupBtn.setTitleColor(.white, for: .normal)
        hangupBtn.titleLabel?.font = .systemFont(ofSize: 12)
        hangupBtn.setImage(UIImage.bf_imageNamed(name: "ic_hangup"), for: .normal)
        hangupBtn.addTarget(self, action: #selector(hangupBtnDidClick), for: .touchUpInside)
        hangupBtn.frame = CGRect(x: UIScreen.width * 0.5 - 42, y: UIScreen.height - UIScreen.safeAreaBottomHeight - 30 - 114, width: 84, height: 114)
        return hangupBtn
    }()
    
    lazy var micBtn: UIButton = {
        let micBtn = UIButton(type: .custom)
        micBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallTurningOffMute"), for: .normal)
        micBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallTurningOnMute"), for: .selected)
        micBtn.setTitleColor(.white, for: .normal)
        micBtn.titleLabel?.font = .systemFont(ofSize: 12)
        micBtn.setImage(UIImage.bf_imageNamed(name: "ic_mute"), for: .normal)
        micBtn.setImage(UIImage.bf_imageNamed(name: "ic_mute_on"), for: .selected)
        micBtn.addTarget(self, action: #selector(mickBtnDidClick), for: .touchUpInside)
        micBtn.frame = CGRect(x: cancelBtn.left - 25 - cancelBtn.width, y: cancelBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return micBtn
    }()
    
    lazy var handFreeBtn: UIButton = {
        let handFreeBtn = UIButton(type: .custom)
        handFreeBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallUsingHeadphone"), for: .normal)
        handFreeBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallUsingSpeaker"), for: .selected)
        handFreeBtn.setTitleColor(.white, for: .normal)
        handFreeBtn.titleLabel?.font = .systemFont(ofSize: 12)
        handFreeBtn.setImage(UIImage.bf_imageNamed(name: "ic_handsfree"), for: .normal)
        handFreeBtn.setImage(UIImage.bf_imageNamed(name: "ic_handsfree_on"), for: .selected)
        handFreeBtn.addTarget(self, action: #selector(handFreeBtnDidClick), for: .touchUpInside)
        handFreeBtn.frame = CGRect(x: cancelBtn.right + 25, y: cancelBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return handFreeBtn
    }()
    
    lazy var rejectBtn: UIButton = {
        let rejectBtn = UIButton(type: .custom)
        rejectBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallReject"), for: .normal)
        rejectBtn.setTitleColor(.white, for: .normal)
        rejectBtn.titleLabel?.font = .systemFont(ofSize: 12)
        rejectBtn.setImage(UIImage.bf_imageNamed(name: "ic_hangup"), for: .normal)
        rejectBtn.addTarget(self, action: #selector(rejectBtnDidClick), for: .touchUpInside)
        rejectBtn.frame = CGRect(x: UIScreen.width * 0.5 - 30 - cancelBtn.width, y: cancelBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return rejectBtn
    }()
    
    lazy var acceptBtn: UIButton = {
        let acceptBtn = UIButton(type: .custom)
        acceptBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallAccept"), for: .normal)
        acceptBtn.setTitleColor(.white, for: .normal)
        acceptBtn.titleLabel?.font = .systemFont(ofSize: 12)
        acceptBtn.setImage(UIImage.bf_imageNamed(name: "ic_dialing"), for: .normal)
        acceptBtn.addTarget(self, action: #selector(acceptBtnDidClick), for: .touchUpInside)
        acceptBtn.frame = CGRect(x: UIScreen.width * 0.5 + 30, y: rejectBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return acceptBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgIcon)
        bgIcon.addSubview(avatarIcon)
        bgIcon.addSubview(durationL)
        bgIcon.addSubview(nickNameL)
        bgIcon.addSubview(noticeL)
        bgIcon.addSubview(cancelBtn)
        cancelBtn.verticalImageAndTitle(spacing: 15)
        bgIcon.addSubview(hangupBtn)
        hangupBtn.verticalImageAndTitle(spacing: 15)
        bgIcon.addSubview(micBtn)
        micBtn.verticalImageAndTitle(spacing: 15)
        bgIcon.addSubview(handFreeBtn)
        handFreeBtn.verticalImageAndTitle(spacing: 15)
        bgIcon.addSubview(rejectBtn)
        rejectBtn.verticalImageAndTitle(spacing: 15)
        bgIcon.addSubview(acceptBtn)
        acceptBtn.verticalImageAndTitle(spacing: 15)
    }
    
    func initDataWithSponsor(isMe: Bool,partner_id: String) {
        
        MSProfileProvider.shared().providerProfile(partner_id) { profile in
            if profile != nil {
                self.bgIcon.kf.setImage(with: URL(string: profile!.avatar))
                self.avatarIcon.kf.setImage(with: URL(string: profile!.avatar))
                self.nickNameL.text = profile?.nick_name
            }
        }
        noticeL.text = isMe ? Bundle.bf_localizedString(key: "TUIKitCallWaitingForAccept") : Bundle.bf_localizedString(key: "TUIKitCallInviteYouVoiceCall")
        cancelBtn.isHidden = !isMe
        micBtn.isHidden = !isMe
        micBtn.isSelected = true
        handFreeBtn.isHidden = !isMe
        handFreeBtn.isSelected = false
        rejectBtn.isHidden = isMe
        acceptBtn.isHidden = isMe
        durationL.isHidden = true
        hangupBtn.isHidden = true
    }
    
    @objc func cancelBtnDidClick() {
        self.delegate?.voice_cancelBtnDidClick()
    }
    
    @objc func hangupBtnDidClick() {
        self.delegate?.voice_hangupBtnDidClick()
    }
    
    @objc func mickBtnDidClick() {
        self.delegate?.voice_mickBtnDidClick()
    }
    
    @objc func handFreeBtnDidClick() {
        self.delegate?.voice_handFreeBtnDidClick()
    }
    
    @objc func rejectBtnDidClick() {
        self.delegate?.voice_rejectBtnDidClick()
    }
    
    @objc func acceptBtnDidClick() {
        self.delegate?.voice_acceptBtnDidClick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
