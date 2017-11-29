//
//  PermissionUtils.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import AVFoundation
import AssetsLibrary
import Photos
import AddressBook
import Contacts

/// 当前APP是否允许访问相册
///
/// - Returns: true表示允许
public func isPermitAccessPhotoLibrary() -> Bool {
    if #available(iOS 8, *) {
        return PHPhotoLibrary.authorizationStatus() != .denied
    } else {
        return ALAssetsLibrary.authorizationStatus()  != .denied
    }
}

/// 当前APP是否允许使用相机
///
/// - Returns: true表示允许
public func isPermitUseCamera() -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    switch status {
    case .authorized:
        return true
    case .denied:
        return false
    default:
        return true
    }
}

/// 当前APP是否允许访问通讯录
///
/// - Returns: true表示允许
public func isPermitAccessAddressBook() -> Bool {
    if #available(iOS 9, *) {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    } else {
        return ABAddressBookGetAuthorizationStatus() == .authorized
    }
}

/// 打开相机设置界面
public func openCameraSettings() {
    if #available(iOS 10, *) {
        UIApplication.shared.open(URL(string: "App-Prefs:root=Privacy&path=CAMERA")!, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(URL(string: "prefs:root=Privacy&path=CAMERA")!)
    }
}

/// 打开当前APP的设置界面
public func openAppPreferences() {
    let url = URL(string: UIApplicationOpenSettingsURLString)!
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

/// 检查权限，并返回特定类型的UIImagePickerController
///
/// - Parameter sourceType: UIImagePickerController类型：photoLibrary或camera
/// - Returns: 返回UIImagePickerController对象，nil表示没有相应的权限
public func imagePicker(for sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController? {
    let pickerController = UIImagePickerController()
    if sourceType == .photoLibrary {
        guard isPermitAccessPhotoLibrary() else {
            openAppPreferences()
            return nil
        }
        pickerController.sourceType = .photoLibrary
    } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
        guard isPermitUseCamera() else {
            openAppPreferences()
            return nil
        }
        pickerController.sourceType = .camera
        pickerController.allowsEditing = false
        pickerController.showsCameraControls = true
    } else { // 相机不可用
        return nil
    }
    return pickerController
}
