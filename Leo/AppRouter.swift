//
//  AppRouter.swift
//  Leo
//
//  Created by Zachary Drossman on 10/25/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

import UIKit

public class AppRouter: NSObject {

    static let router = AppRouter()

    var window: UIWindow?

    var presentingVC: UIViewController?
    private var _presentingVC: UIViewController? {
        get {
            return presentingVC ?? window?.rootViewController
        }
    }

    var navigationVC: UINavigationController?

    private var transitioningDelegate: LEOTransitioningDelegate?

    func setRoot(window: UIWindow) {

        self.window = window
        navigationVC = _presentingVC as? UINavigationController
    }

    private func presentExpandedCard(viewController: UINavigationController) {

        // TODO: Add a method to ensure the feed is available to present the expanded card

        navigationVC = viewController

        transitioningDelegate = LEOTransitioningDelegate(transitionAnimatorType: .cardModal)
        viewController.transitioningDelegate = transitioningDelegate
        viewController.modalPresentationStyle = .fullScreen
        _presentingVC?.present(viewController, animated: true, completion: nil)
    }

//    MARK: Navigation Controller
    private func pushOntoCurrentNavStack(viewController: UIViewController) {
        navigationVC?.pushViewController(viewController, animated: true)
    }

    private func resetNavStateThenPush(viewController: UIViewController) {

    }

    func presentCallUsConfirmationAlert(name: String, phoneNumber: String) {

        let alert = UIAlertController(
            title: "You are about to call\n\(name)\n\(phoneNumber)",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Call", style: .default) { _ in
            ActionHandler.handle(action: ActionCreators.callPhone(phoneNumber: phoneNumber))
        }
    }

//    MARK: present specific expanded cards
    func presentExpandedCardScheduling(appointment: Appointment?) {

        let emptyAppointment: ()->(Appointment?) = {
            let policy = LEOCachePolicy.cacheOnly()
            guard let practice = LEOPracticeService(cachePolicy: policy).getCurrentPractice() else { return nil }
            guard let bookedBy = LEOUserService(cachePolicy: policy).getCurrentUser() else { return nil }
            guard let family = LEOFamilyService(cachePolicy: policy).getFamily() else { return nil }
            let patient = family.patients.count == 1 ? family.patients.first : nil
            return Appointment(patient: patient, practice: practice, bookedBy: bookedBy)
        }

        guard let appointment = appointment ?? emptyAppointment() else { return }
        guard let viewController = configureAppointmentViewController(appointment: appointment) else { return }

        presentExpandedCard(viewController: viewController)
    }

    func presentExpandedCardConversation(conversation: Conversation) {
        guard let viewController = configureConversationViewController(conversation: conversation) else { return }
        presentExpandedCard(viewController: viewController)
    }

    func presentExpandedCardSurvey(survey: Survey) {
        guard let viewController = configureSurveyNavigationController(survey: survey) else { return }
        presentExpandedCard(viewController: viewController)
    }

//    MARK: configure expanded card VCs
    private func configureSurveyViewController(survey: Survey, index: Int) -> SurveyViewController? {

        let surveyStoryboard = UIStoryboard(name: "Survey", bundle: nil)
        guard let surveyVC = surveyStoryboard.instantiateInitialViewController() as? SurveyViewController
            else { return nil }

        guard index < survey.questions.count else { return nil }

        surveyVC.showsBackButton = index > 0
        surveyVC.question = survey.questions[index]

        surveyVC.routeNext = {

            guard let nextQuestionVC =
                self.configureSurveyViewController(
                    survey: survey,
                    index: index + 1
                ) else { return }

            self.pushOntoCurrentNavStack(viewController: nextQuestionVC)
        }

        surveyVC.routeDismissExpandedCard = {
            self._presentingVC?.dismiss(
                animated: true,
                completion: nil
            )
        }
        return surveyVC
    }

    private func configureSurveyNavigationController(survey: Survey) -> UINavigationController? {

        guard let surveyVC = configureSurveyViewController(survey: survey, index: 0) else { return nil }

        let surveyNavController = UINavigationController(rootViewController: surveyVC)
        return surveyNavController
    }

    private func configureConversationViewController(conversation: Conversation) -> UINavigationController? {

        let conversationStoryboard = UIStoryboard(name: "Conversation", bundle: nil)
        guard let conversationNavController = conversationStoryboard.instantiateInitialViewController() as? UINavigationController else { return nil }
        guard let conversationVC = conversationNavController.viewControllers.first as? LEOConversationViewController else { return nil }

        conversationVC.conversation = conversation
        conversationVC.tintColor = .leo_blue()

        return conversationNavController
    }

    private func configureAppointmentViewController(appointment: Appointment) -> UINavigationController? {

        let appointmentStoryboard = UIStoryboard(name: "Appointment", bundle: nil)
        guard let appointmentNavController = appointmentStoryboard.instantiateInitialViewController() as? UINavigationController else { return nil }
        guard let appointmentVC = appointmentNavController.viewControllers.first as? LEOAppointmentViewController else { return nil }

        appointmentVC.associatedAppointment = appointment
        appointmentVC.tintColor = .leo_green()

        return appointmentNavController
    }

}
