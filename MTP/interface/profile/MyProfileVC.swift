// @copyright Trollwerks Inc.

import Anchorage
import UIKit

final class MyProfileVC: UIViewController {

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var birthdayLabel: UILabel?
    @IBOutlet private var followersLabel: UILabel?
    @IBOutlet private var followingLabel: UILabel?

    @IBOutlet private var tabsHolder: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
        configureTabsHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        style.standard.apply()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case R.segue.myProfileVC.directEdit.identifier,
             R.segue.myProfileVC.showEditProfile.identifier,
             R.segue.myProfileVC.showSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension MyProfileVC {

    @IBAction func unwindToMyProfile(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func configureHeaderView() {
        guard let user = gestalt.user else { return }

        headerView?.round(corners: [.topLeft, .topRight], by: 5)

        log.debug("TO DO: avatar")

        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.country.countryName

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdayLabel?.text = dateFormatter.string(from: user.birthday)

        log.debug("TO DO: follow counts")
        let followersCount = 0
        let followers = Localized.followers(followersCount)
        followersLabel?.text = followers
        let followingCount = 0
        let following = Localized.following(followingCount)
        followingLabel?.text = following
    }

    func configureTabsHolder() {
        guard let holder = tabsHolder else { return }

        let tabsVC = MyProfileTabsVC()
        addChildViewController(tabsVC)
        holder.addSubview(tabsVC.view)
        tabsVC.view.edgeAnchors == holder.edgeAnchors
        tabsVC.didMove(toParentViewController: self)
    }
}