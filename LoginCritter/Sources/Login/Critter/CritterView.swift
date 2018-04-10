//
//  CritterView.swift
//  LoginCritter
//
//  Created by Christopher Goldsby on 3/30/18.
//  Copyright © 2018 Christopher Goldsby. All rights reserved.
//

import UIKit

final class CritterView: UIView {

    private var isDoeEyed = false

    private let body = UIImageView(image: UIImage.Critter.body)
    private let head = UIImageView(image: UIImage.Critter.head)
    private let leftEar = UIImageView(image: UIImage.Critter.leftEar)
    private let leftEye = UIImageView(image: UIImage.Critter.eye)
    private let mouthOpen = UIImageView(image: UIImage.Critter.mouthOpen)
    private let muzzle = UIImageView(image: UIImage.Critter.muzzle)
    private let nose = UIImageView(image: UIImage.Critter.nose)
    private let rightEar = UIImageView(image: UIImage.Critter.rightEar)
    private let rightEye = UIImageView(image: UIImage.Critter.eye)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setUpView() {
        backgroundColor = Colors.light
        setUpMask()

        addSubview(body)
        body.layer.zPosition = -30
        body.frame = CGRect(x: 33.9, y: 109.2, width: 92.1, height: 73.4)

        addSubview(leftEar)
        leftEar.layer.zPosition = -30
        leftEar.frame = CGRect(x: 20.1, y: 48.8, width: 36.7, height: 36.3)

        addSubview(rightEar)
        rightEar.layer.zPosition = -30
        rightEar.frame = CGRect(x: 107.1, y: 48.8, width: 36.7, height: 36.3)

        addSubview(head)
        head.frame = CGRect(x: 29.2, y: 52.1, width: 105.5, height: 90.9)

        head.addSubview(leftEye)
        leftEye.frame = CGRect(x: 21.8, y: 28.8, width: 11.7, height: 11.7)

        head.addSubview(rightEye)
        rightEye.frame = CGRect(x: 72.4, y: 28.8, width: 11.7, height: 11.7)

        head.addSubview(muzzle)
        muzzle.frame = CGRect(x: 24, y: 43, width: 57.5, height: 46.8)

        muzzle.addSubview(nose)
        nose.frame = CGRect(x: 22.4, y: 1.7, width: 12.7, height: 9.6)

        muzzle.addSubview(mouthOpen)
        mouthOpen.frame = CGRect(x: 15.5, y: 24.6, width: 26.4, height: 18.7)
    }

    private func setUpMask() {
        mask = UIView(frame: bounds)
        mask?.backgroundColor = .black
        mask?.layer.cornerRadius = bounds.width / 2
    }

    // MARK: - Animation

    private enum Parts {
        case body
        case head
        case leftEar
        case leftEye
        case mouthOpen
        case muzzle
        case nose
        case rightEar
        case rightEye
    }

    private var focusCritterStartAnimation: UIViewPropertyAnimator?
    private var focusCritterEndAnimation: UIViewPropertyAnimator?
    private var focusIntermediateState = [Parts : CATransform3D]()

    func startHeadRotation(startAt fractionComplete: Float) {
        let shouldStoreCurrentState = focusCritterEndAnimation != nil

        stopAllAnimations()

        if shouldStoreCurrentState {
            storeCurrentState()
        }

        focusCritterStartAnimation = UIViewPropertyAnimator(
            duration: 0.2,
            curve: .easeIn,
            animations: { self.focusIntermediateState.isEmpty ? self.focusCritterInitialState() : self.restoreState() })

        focusCritterEndAnimation = UIViewPropertyAnimator(
            duration: 0.2,
            curve: .linear,
            animations: focusCritterFinalState
        )

        focusCritterStartAnimation?.addCompletion {
            [weak self] _ in
            self?.focusCritterInitialState()
            self?.focusCritterEndAnimation?.fractionComplete = CGFloat(fractionComplete)
        }

        focusCritterStartAnimation?.startAnimation()
    }

    func updateHeadRotation(to fractionComplete: Float) {
        focusCritterEndAnimation?.fractionComplete = CGFloat(fractionComplete)
    }

    func stopHeadRotation() {
        let shouldStoreCurrentState = focusCritterEndAnimation != nil

        stopAllAnimations()

        if shouldStoreCurrentState {
            storeCurrentState()
        }

        let neutralAnimation = UIViewPropertyAnimator(duration: 0.1725, curve: .easeIn) {
            self.body.layer.transform = .identity
            self.head.layer.transform = .identity
            self.leftEye.layer.transform = .identity
            self.rightEye.layer.transform = .identity
            self.leftEar.layer.transform = .identity
            self.rightEar.layer.transform = .identity
            self.muzzle.layer.transform = .identity
            self.nose.layer.transform = .identity
            self.mouthOpen.layer.transform = .identity
        }

        neutralAnimation.addCompletion {
            _ in
            self.leftEar.layer.zPosition = -30
            self.rightEar.layer.zPosition = -30
        }

        neutralAnimation.startAnimation()
    }

    func validateAnimation() {
        isDoeEyed = !isDoeEyed

        let duration = 0.125
        let eyeAnimationKey = "eyeCrossFade"
        leftEye.layer.removeAnimation(forKey: eyeAnimationKey)
        rightEye.layer.removeAnimation(forKey: eyeAnimationKey)

        let crossFade = CABasicAnimation(keyPath: "contents")
        crossFade.duration = duration
        crossFade.fromValue = isDoeEyed ? UIImage.Critter.eye.cgImage : UIImage.Critter.doeEye.cgImage
        crossFade.toValue = isDoeEyed ? UIImage.Critter.doeEye.cgImage : UIImage.Critter.eye.cgImage
        crossFade.fillMode = kCAFillModeForwards
        crossFade.isRemovedOnCompletion = false

        leftEye.layer.add(crossFade, forKey: eyeAnimationKey)
        rightEye.layer.add(crossFade, forKey: eyeAnimationKey)

        let dimension = isDoeEyed ? 12.7 : 11.7
        let validateAnimation = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            self.leftEye.layer.bounds = CGRect(x: 0, y: 0, width: dimension, height: dimension)
            self.rightEye.layer.bounds = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        }

        validateAnimation.startAnimation()
    }

    private func stopAllAnimations() {
        focusCritterStartAnimation?.stopAnimation(true)
        focusCritterStartAnimation = nil

        focusCritterEndAnimation?.stopAnimation(true)
        focusCritterEndAnimation = nil
    }

    private func focusCritterFinalState() {
        let bodyTransform = CATransform3D
            .identity
            .perspective(-1.0 / 500)
            .rotate(.y, by: (10.0).degrees)
        body.layer.transform = bodyTransform

        let headTransform = CATransform3D
            .identity
            .perspective(-1.0 / 500)
            .rotate(.x, by: (-18.0).degrees)
            .rotate(.y, by: (18.0).degrees)

        head.layer.transform = headTransform

        let eyeScale: CGFloat = 1.12
        let eyeTransform = CATransform3D
            .identity
            .scale(.x, by: eyeScale)
            .scale(.y, by: eyeScale)
            .scale(.z, by: 1.01) // 🎩✨ Magic to prevent 'jumping'

        var p1 = CGPoint(x: 21.8, y: 28.8)
        var p2 = CGPoint(x: 11.5, y: 37)

        leftEye.layer.transform = eyeTransform
            .translate(.x, by: -(p2.x - p1.x))
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 72.4, y: 28.8)
        p2 = CGPoint(x: 62.1, y: 37)

        rightEye.layer.transform = eyeTransform
            .translate(.x, by: -(p2.x - p1.x))
            .translate(.y, by: p2.y - p1.y)

        rightEar.layer.transform = headTransform
            .translate(.x, by: -10)
        rightEar.layer.zPosition = -30

        leftEar.layer.transform = headTransform
            .translate(.x, by: 2)
            .translate(.y, by: 12)
            .rotate(.z, by: (-8.0).degrees)
        leftEar.layer.zPosition = 30

        p1 = CGPoint(x: 24, y: 43)
        p2 = CGPoint(x: 12.9, y: 45.1)

        muzzle.layer.transform = CATransform3D
            .identity
            .translate(.x, by: -(p2.x - p1.x))
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 22.4, y: 1.7)
        p2 = CGPoint(x: 13.2, y: 5.2)

        nose.layer.transform = CATransform3D
            .identity
            .translate(.x, by: -(p2.x - p1.x))
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 15.5, y: 24.6)
        p2 = CGPoint(x: 14.9, y: 22.1)

        mouthOpen.layer.transform = CATransform3D
            .identity
            .translate(.x, by: -(p2.x - p1.x))
            .translate(.y, by: p2.y - p1.y)
    }

    private func focusCritterInitialState() {
        let bodyTransform = CATransform3D
            .identity
            .perspective(-1.0 / 500)
            .rotate(.y, by: (-10.0).degrees)
        body.layer.transform = bodyTransform

        let headTransform = CATransform3D
            .identity
            .perspective(-1.0 / 500)
            .rotate(.x, by: (-18.0).degrees)
            .rotate(.y, by: (-18.0).degrees)
        head.layer.transform = headTransform

        let eyeScale: CGFloat = 1.12
        let eyeTransform = CATransform3D
            .identity
            .scale(.x, by: eyeScale)
            .scale(.y, by: eyeScale)
            .scale(.z, by: 1.01) // 🎩✨ Magic to prevent 'jumping'

        var p1 = CGPoint(x: 21.8, y: 28.8)
        var p2 = CGPoint(x: 11.5, y: 37)

        leftEye.layer.transform = eyeTransform
            .translate(.x, by: p2.x - p1.x)
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 72.4, y: 28.8)
        p2 = CGPoint(x: 62.1, y: 37)

        rightEye.layer.transform = eyeTransform
            .translate(.x, by: p2.x - p1.x)
            .translate(.y, by: p2.y - p1.y)

        leftEar.layer.transform = headTransform
            .translate(.x, by: 10)
        leftEar.layer.zPosition = -30

        rightEar.layer.transform = headTransform
            .translate(.x, by: -2)
            .translate(.y, by: 12)
            .rotate(.z, by: 8.0.degrees)
        rightEar.layer.zPosition = 30

        p1 = CGPoint(x: 24, y: 43)
        p2 = CGPoint(x: 12.9, y: 45.1)

        muzzle.layer.transform = CATransform3D
            .identity
            .translate(.x, by: p2.x - p1.x)
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 22.4, y: 1.7)
        p2 = CGPoint(x: 13.2, y: 5.2)

        nose.layer.transform = CATransform3D
            .identity
            .translate(.x, by: p2.x - p1.x)
            .translate(.y, by: p2.y - p1.y)

        p1 = CGPoint(x: 15.5, y: 24.6)
        p2 = CGPoint(x: 14.9, y: 22.1)

        mouthOpen.layer.transform = CATransform3D
            .identity
            .translate(.x, by: p2.x - p1.x)
            .translate(.y, by: p2.y - p1.y)
    }

    func storeCurrentState() {
        focusIntermediateState[.body] = body.layer.transform
        focusIntermediateState[.head] = head.layer.transform
        focusIntermediateState[.leftEye] = leftEye.layer.transform
        focusIntermediateState[.rightEye] = rightEye.layer.transform
        focusIntermediateState[.leftEar] = leftEar.layer.transform
        focusIntermediateState[.rightEar] = rightEar.layer.transform
        focusIntermediateState[.muzzle] = muzzle.layer.transform
        focusIntermediateState[.nose] = nose.layer.transform
        focusIntermediateState[.mouthOpen] = mouthOpen.layer.transform
    }

    func restoreState() {
        body.layer.transform = focusIntermediateState[.body]!
        head.layer.transform = focusIntermediateState[.head]!
        leftEye.layer.transform = focusIntermediateState[.leftEye]!
        rightEye.layer.transform = focusIntermediateState[.rightEye]!
        leftEar.layer.transform = focusIntermediateState[.leftEar]!
        rightEar.layer.transform = focusIntermediateState[.rightEar]!
        muzzle.layer.transform = focusIntermediateState[.muzzle]!
        nose.layer.transform = focusIntermediateState[.nose]!
        mouthOpen.layer.transform = focusIntermediateState[.mouthOpen]!
    }
}