// @copyright Trollwerks Inc.

import UIKit

protocol FaqCellDelegate: AnyObject {

    func set(faq: Int, answer visible: Bool)
}

final class FaqVC: UITableViewController, ServiceProvider {

    typealias Faq = (question: String, answer: String)
    private typealias Segues = R.segue.faqVC

    @IBOutlet private var backgroundView: UIView?

    private let faqs: [Faq] = [
        (Localized.question0(), Localized.answer0()),
        (Localized.question1(), Localized.answer1()),
        (Localized.question2(), Localized.answer2()),
        (Localized.question3(), Localized.answer3()),
        (Localized.question4(), Localized.answer4()),
        (Localized.question5(), Localized.answer5()),
        (Localized.question6(), Localized.answer6()),
        (Localized.question7(), Localized.answer7()),
        (Localized.question8(), Localized.answer8()),
        (Localized.question9(), Localized.answer9()),
        (Localized.question10(), Localized.answer10()),
        (Localized.question11(), Localized.answer11()),
        (Localized.question12(), Localized.answer12()),
        (Localized.question13(), Localized.answer13()),
        (Localized.question14(), Localized.answer14())
    ]
    private var expanded = [Bool] (repeating: false, count: 15)

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
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
        case Segues.unwindFromFaq.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewControllerDataSource

extension FaqVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.faqCell,
            for: indexPath) ?? FaqCell()

        let index = indexPath.row
        cell.set(faq: faqs[index],
                 index: index,
                 expanded: expanded[index],
                 delegate: self)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FaqVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Injectable

extension FaqVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> FaqVC {
        return self
    }

    func requireInjections() {
        backgroundView.require()
    }
}

// MARK: - FaqCellDelegate

extension FaqVC: FaqCellDelegate {

    func set(faq: Int, answer visible: Bool) {
        expanded[faq] = visible
        // suppress animation to kill white flicker
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}

final class FaqCell: UITableViewCell {

    @IBOutlet private var contentStack: UIStackView?
    @IBOutlet private var questionLabel: UILabel?
    @IBOutlet private var answerLabel: UILabel?
    @IBOutlet private var toggleButton: UIButton?

    private var index = 0
    private weak var delegate: FaqCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setAnswerShown()
    }

    override func prepareForReuse() {
        index = 0
        delegate = nil
        questionLabel?.text = nil
        answerLabel?.text = nil
        toggleButton?.isSelected = false
        setAnswerShown()

        super.prepareForReuse()
    }

    func set(faq: FaqVC.Faq,
             index: Int,
             expanded: Bool,
             delegate: FaqCellDelegate) {
        self.index = index
        self.delegate = delegate
        questionLabel?.text = faq.question
        answerLabel?.text = faq.answer
        toggleButton?.isSelected = expanded
        setAnswerShown()
    }
}

private extension FaqCell {

    @IBAction func toggleTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if setAnswerShown() {
            delegate?.set(faq: self.index,
                          answer: sender.isSelected)
        }
    }

    @discardableResult func setAnswerShown() -> Bool {
        guard let button = toggleButton,
              let label = answerLabel else { return false }
        let show = button.isSelected
        let shown = !label.isHidden
        switch (show, shown) {
        case (true, false), (false, true):
            label.isHidden = !show
            return true
        default:
            return false
        }
    }
}
