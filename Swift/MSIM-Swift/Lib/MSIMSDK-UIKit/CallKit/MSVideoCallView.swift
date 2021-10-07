//
//  MSVideoCallView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/28.
//

import UIKit
import MSIMSDK
import Kingfisher

protocol MSVideoCallViewDelegate: NSObjectProtocol {
    
    func video_remoteViewDidTap()
    func video_cancelBtnDidClick()
    func video_cameraBtnDidClick()
    func video_rejectBtnDidClick()
    func video_acceptBtnDidClick()
    func video_hangupBtnDidClick()
}
class MSVideoCallView: UIView {

    weak var delegate: MSVideoCallViewDelegate?
    
    lazy var localView: UIView = {
        let localView = UIView(frame: UIScreen.main.bounds)
        return localView
    }()

    lazy var remoteView: UIView = {
        let remoteView = UIView(frame: CGRect(x: UIScreen.width - 20 - 90, y: UIScreen.status_navi_height, width: 90, height: 160))
        remoteView.layer.cornerRadius = 6
        remoteView.clipsToBounds = true
        return remoteView
    }()
    
    lazy var avatarIcon: UIImageView = {
        let avatarIcon = UIImageView(frame: CGRect(x: 20, y: UIScreen.status_navi_height, width: 70, height: 70))
        avatarIcon.layer.cornerRadius = 4
        avatarIcon.layer.masksToBounds = true
        avatarIcon.contentMode = .scaleAspectFill
        return avatarIcon
    }()
    
    lazy var durationL: UILabel = {
        let durationL = UILabel(frame: CGRect(x: UIScreen.width * 0.5 - 50, y: UIScreen.status_navi_height, width: 100, height: 20))
        durationL.textColor = .white
        durationL.font = .systemFont(ofSize: 16)
        durationL.textAlignment = .center
        return durationL
    }()
    
    lazy var nickNameL: UILabel = {
        let nickNameL = UILabel(frame: CGRect(x: avatarIcon.right + 15, y: avatarIcon.top, width: 200, height: 35))
        nickNameL.font = .systemFont(ofSize: 20)
        nickNameL.textColor = .white
        nickNameL.textAlignment = .center
        return nickNameL
    }()
    
    lazy var noticeL: UILabel = {
        let noticeL = UILabel(frame: CGRect(x: nickNameL.left, y: nickNameL.bottom + 12, width: 200, height: 20))
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
        hangupBtn.frame = CGRect(x: UIScreen.width * 0.5 - cancelBtn.width - 30, y: cancelBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return hangupBtn
    }()
    
    lazy var cameraBtn: UIButton = {
        let cameraBtn = UIButton(type: .custom)
        cameraBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitCallCameraSwitch"), for: .normal)
        cameraBtn.setTitleColor(.white, for: .normal)
        cameraBtn.titleLabel?.font = .systemFont(ofSize: 12)
        cameraBtn.setImage(UIImage.bf_imageNamed(name: "ic_camera"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraBtnDidClick), for: .touchUpInside)
        cameraBtn.frame = CGRect(x: UIScreen.width * 0.5 + 30, y: hangupBtn.top, width: cancelBtn.width, height: cancelBtn.height)
        return cameraBtn
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
        addSubview(localView)
        addSubview(remoteView)
        
        let remoteTap = UITapGestureRecognizer(target: self, action: #selector(remoteViewTap))
        remoteView.addGestureRecognizer(remoteTap)
        
        addSubview(avatarIcon)
        addSubview(durationL)
        addSubview(nickNameL)
        addSubview(noticeL)
        addSubview(cancelBtn)
        cancelBtn.verticalImageAndTitle(spacing: 15)
        addSubview(hangupBtn)
        hangupBtn.verticalImageAndTitle(spacing: 15)
        addSubview(cameraBtn)
        cameraBtn.verticalImageAndTitle(spacing: 15)
        addSubview(rejectBtn)
        rejectBtn.verticalImageAndTitle(spacing: 15)
        addSubview(acceptBtn)
        acceptBtn.verticalImageAndTitle(spacing: 15)
    }
    
    func initDataWithSponsor(isMe: Bool,partner_id: String) {
        
        MSProfileProvider.shared().providerProfile(partner_id) { profile in
            if profile != nil {
                self.avatarIcon.kf.setImage(with: URL(string: profile!.avatar))
                self.nickNameL.text = profile?.nick_name
            }
        }
        noticeL.text = isMe ? Bundle.bf_localizedString(key: "TUIKitCallWaitingForAccept") : Bundle.bf_localizedString(key: "TUIKitCallInviteYouVideoCall")
        cancelBtn.isHidden = !isMe
        cameraBtn.isHidden = true
        rejectBtn.isHidden = isMe
        acceptBtn.isHidden = isMe
        durationL.isHidden = true
        hangupBtn.isHidden = true
        remoteView.isHidden = true
    }
    
    @objc func remoteViewTap() {
        self.delegate?.video_remoteViewDidTap()
    }
    
    @objc func cancelBtnDidClick() {
        self.delegate?.video_cancelBtnDidClick()
    }
    
    @objc func cameraBtnDidClick() {
        self.delegate?.video_cameraBtnDidClick()
    }
    
    @objc func rejectBtnDidClick() {
        self.delegate?.video_rejectBtnDidClick()
    }
    
    @objc func acceptBtnDidClick() {
        self.delegate?.video_acceptBtnDidClick()
    }
    
    @objc func hangupBtnDidClick() {
        self.delegate?.video_hangupBtnDidClick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
