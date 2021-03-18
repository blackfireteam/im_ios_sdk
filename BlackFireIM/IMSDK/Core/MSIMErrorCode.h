//
//  MSIMErrorCode.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#ifndef MSIMErrorCode_h
#define MSIMErrorCode_h

enum ERROR_CODE {
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （一）IM SDK 的错误码
    //
    /////////////////////////////////////////////////////////////////////////////////
    
    // 通用错误码
    ERR_SUCC                                    = 0,///< 无错误。
    ERR_IO_OPERATION_FAILED                     = 6022,    ///< 操作本地 IO 错误，检查是否有读写权限，磁盘是否已满。
    ERR_PARSE_RESPONSE_FAILED                   = 6001,    ///< PB 解析失败，内部错误
    ERR_SERIALIZE_REQ_FAILED                    = 6002,    ///< PB 序列化失败，内部错误
    ERR_SDK_NOT_INITIALIZED                     = 6013,    ///< IM SDK 未初始化，初始化成功回调之后重试
    ERR_LOADMSG_FAILED                          = 6005,    ///< 加载本地数据库操作失败，可能存储文件有损坏
    ERR_SDK_COMM_FILE_NOT_FOUND                 = 7004,    ///< 文件不存在，请检查文件路径是否正确
    ERR_SDK_NOT_LOGGED_IN                       = 6014,    ///< IM SDK 未登录，请先登录，成功回调之后重试，或者已被踢下线，可使用 TIMManager getLoginUser 检查当前是否在线。
    ERR_NO_PREVIOUS_LOGIN                       = 6026,    ///< 自动登录时，并没有登录过该用户，这时候请调用 login 接口重新登录。
    ERR_USER_SIG_EXPIRED                        = 6206,    ///< UserSig 过期，请重新获取有效的 UserSig 后再重新登录。
    ERR_LOGIN_KICKED_OFF_BY_OTHER               = 6208,    ///< 其他终端登录同一个帐号，引起已登录的帐号被踢，需重新登录。
    ERR_SDK_ACCOUNT_LOGIN_IN_PROCESS            = 7501,    ///< 登录正在执行中，例如，第一次 login 或 autoLogin 操作在回调前，后续的 login 或 autoLogin 操作会返回该错误码。
    ERR_SDK_ACCOUNT_LOGOUT_IN_PROCESS           = 7502,    ///< 登出正在执行中，例如，第一次 logout 操作在回调前，后续的 logout 操作会返回该错误码
    
    ERR_SDK_DB_WRITE_FAIL                       = 8001, ///< 数据库写入消息失败
    ERR_SDK_DB_DEL_CONVERSATION_FAIL            = 8002,   ///<数据库删除会话记录失败
    
    
    ERR_USER_SEND_EMPTY                         = 9001,    ///< 用户待发送的消息内容为空
    ERR_USER_PARAMS_ERROR                       = 9002,    ///< 参数异常
    ERR_IM_TEXT_MAX_ERROR                       = 9003,    ///< 文本消息长度超过限制
    ERR_IM_IMAGE_TYPE_ERROR                     = 9004,    ///<图片类型不支持
    ERR_IM_IMAGE_MAX_ERROR                      = 9005,    ///<图片大小超过限制
};

#endif /* MSIMErrorCode_h */
