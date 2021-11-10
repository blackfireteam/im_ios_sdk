//
//  MSMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/6.
//

import UIKit
import MSIMSDK
import Kingfisher


public protocol MSMessageCellDelegate: NSObjectProtocol {
    
    ///长按消息回调
    func onLongPressMessage(cell: MSMessageCell)
    ///重发消息点击回调
    func onRetryMessage(cell: MSMessageCell)
    ///点击消息回调
    func onSelectMessage(cell: MSMessageCell)
    ///点击消息单元中消息头像的回调
    func onSelectMessageAvatar(cell: MSMessageCell)
}
open class MSMessageCell: UITableViewCell {

    public weak var delegate: MSMessageCellDelegate?
    
    public var avatarView: UIImageView!
    
    public var nameLabel: UILabel!
    
    public var container: UIView!
    
    public var indicator: UIActivityIndicatorView!
    
    public var retryView: UIImageView!
    
    public var readReceiptLabel: UILabel!
    
    public private(set) var messageData: MSMessageCellData?
    
    public func fillWithData(data: MSMessageCellData) {
        self.messageData = data
        avatarView.image = data.defaultAvatar
        if let fromUid = data.elem?.fromUid {
            let profile = MSProfileProvider.shared().providerProfile(fromLocal: fromUid)
            avatarView.kf.setImage(with: URL(string: profile?.avatar ?? ""),placeholder: data.defaultAvatar)
            nameLabel.text = profile?.nick_name
        }
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = 40 * 0.5
        
        if data.elem?.sendStatus == .MSG_STATUS_SEND_FAIL {
            indicator.stopAnimating()
            retryView.image = UIImage.bf_imageNamed(name: "msg_error")
        }else if data.elem?.sendStatus == .MSG_STATUS_SENDING {
            indicator.startAnimating()
            retryView.image = nil
        }else {
            indicator.stopAnimating()
            retryView.image = nil
        }
        if data.direction == .outGoing {
            readReceiptLabel.isHidden = false
            if data.elem?.sendStatus == .MSG_STATUS_SEND_SUCC {
                if data.elem?.chatType == .MSIM_CHAT_TYPE_C2C {
                    readReceiptLabel.text = data.elem?.readStatus == .MSG_STATUS_UNREAD ? Bundle.bf_localizedString(key: "Deliveried") : Bundle.bf_localizedString(key: "Read")
                }else {
                    readReceiptLabel.text = Bundle.bf_localizedString(key: "Deliveried")
                }
            }else if data.elem?.sendStatus == .MSG_STATUS_SENDING {
                readReceiptLabel.text = Bundle.bf_localizedString(key: "Sending")
            }else {
                readReceiptLabel.text = Bundle.bf_localizedString(key: "NotDeliveried")
            }
        }else {
            readReceiptLabel.isHidden = true
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        avatarView = UIImageView()
        avatarView.contentMode = .scaleAspectFill
        contentView.addSubview(avatarView)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(onSelectMessageAvatar))
        avatarView.addGestureRecognizer(tap1)
        avatarView.isUserInteractionEnabled = true
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textColor = .systemGray
        contentView.addSubview(nameLabel)
        
        container = UIView()
        container.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSelectMessage))
        container.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        container.addGestureRecognizer(longPress)
        contentView.addSubview(container)
        
        indicator = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(indicator)
        
        retryView = UIImageView()
        retryView.isUserInteractionEnabled = true
        let resendTap = UITapGestureRecognizer(target: self, action: #selector(onRetryMessage))
        retryView.addGestureRecognizer(resendTap)
        contentView.addSubview(retryView)
        
        readReceiptLabel = UILabel()
        readReceiptLabel.isHidden = true
        readReceiptLabel.font = .systemFont(ofSize: 12)
        readReceiptLabel.textColor = .systemGray
        readReceiptLabel.textAlignment = .right
        contentView.addSubview(readReceiptLabel)
        
        selectionStyle = .none
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let nameSize = nameLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        if messageData?.direction == .inComing {
            avatarView.left = 8
            avatarView.top = 5
            avatarView.width = 40
            avatarView.height = 40
            
            if messageData?.showName == true {
                nameLabel.frame = CGRect(x: avatarView.right + 5, y: avatarView.top, width: nameSize.width, height: 20)
                nameLabel.isHidden = false
            }else {
                nameLabel.isHidden = true
                nameLabel.frame = CGRect(x: avatarView.right + 5, y: avatarView.top, width: nameSize.width, height: 0)
            }
            let csize = messageData?.contentSize() ?? .zero
            container.left = nameLabel.left
            container.top = nameLabel.height + 5 + avatarView.top
            container.width = csize.width
            container.height = csize.height
            
            indicator.sizeToFit()
            indicator.frame = .zero
            retryView.frame = indicator.frame
        }else {
            avatarView.top = 5
            avatarView.width = 40
            avatarView.height = 40
            avatarView.right = contentView.width - 8
            
            if messageData?.showName == true {
                nameLabel.frame = CGRect(x: avatarView.left - 5 - nameSize.width, y: avatarView.top, width: nameSize.width, height: 20)
                nameLabel.isHidden = false
            }else {
                nameLabel.isHidden = true
                nameLabel.height = 0
                nameLabel.frame = CGRect(x: avatarView.left - 5 - nameSize.width, y: avatarView.top, width: nameSize.width, height: 0)
            }
            let csize = messageData?.contentSize() ?? .zero
            container.top = nameLabel.height + 5 + avatarView.top
            container.width = csize.width
            container.height = csize.height
            container.right = nameLabel.right
            
            indicator.sizeToFit()
            indicator.centerY = container.centerY
            indicator.left = container.left - 8 - indicator.width
            retryView.frame = indicator.frame
            readReceiptLabel.frame = CGRect(x: container.right - 80, y: container.bottom + 3, width: 80, height: 12)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension MSMessageCell {
    
    @objc func onLongPress(ges: UIGestureRecognizer) {
        
        if ges.isKind(of: UILongPressGestureRecognizer.self) && ges.state == .began {
            delegate?.onLongPressMessage(cell: self)
        }
    }
    
    @objc func onRetryMessage() {
        if messageData?.elem?.sendStatus == .MSG_STATUS_SEND_FAIL {
            delegate?.onRetryMessage(cell: self)
        }
    }
    
    @objc func onSelectMessage() {
        delegate?.onSelectMessage(cell: self)
    }
    
    @objc func onSelectMessageAvatar() {
        delegate?.onSelectMessageAvatar(cell: self)
    }
}
