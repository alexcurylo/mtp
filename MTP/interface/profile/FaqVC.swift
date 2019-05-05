// @copyright Trollwerks Inc.

import UIKit

protocol FaqCellDelegate: AnyObject {

    func set(faq: Int, answer visible: Bool)
}

final class FaqVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.faqVC

    @IBOutlet private var backgroundView: UIView?

    private var faqs: [FaqCellModel] = [
        FaqCellModel(index: 0,
                     question: Localized.question0(),
                     answer: Localized.answer0(),
                     isExpanded: false),
        FaqCellModel(index: 1,
                     question: Localized.question1(),
                     answer: Localized.answer1(),
                     isExpanded: false),
        FaqCellModel(index: 2,
                     question: Localized.question2(),
                     answer: Localized.answer2(),
                     isExpanded: false),
        FaqCellModel(index: 3,
                     question: Localized.question3(),
                     answer: Localized.answer3(),
                     isExpanded: false),
        FaqCellModel(index: 4,
                     question: Localized.question4(),
                     answer: Localized.answer4(),
                     isExpanded: false),
        FaqCellModel(index: 5,
                     question: Localized.question5(),
                     answer: Localized.answer5(),
                     isExpanded: false),
        FaqCellModel(index: 6,
                     question: Localized.question6(),
                     answer: Localized.answer6(),
                     isExpanded: false),
        FaqCellModel(index: 7,
                     question: Localized.question7(),
                     answer: Localized.answer7(),
                     isExpanded: false),
        FaqCellModel(index: 8,
                     question: Localized.question8(),
                     answer: Localized.answer8(),
                     isExpanded: false),
        FaqCellModel(index: 9,
                     question: Localized.question9(),
                     answer: Localized.answer9(),
                     isExpanded: false),
        FaqCellModel(index: 10,
                     question: Localized.question10(),
                     answer: Localized.answer10(),
                     isExpanded: false),
        FaqCellModel(index: 11,
                     question: Localized.question11(),
                     answer: Localized.answer11(),
                     isExpanded: false),
        FaqCellModel(index: 12,
                     question: Localized.question12(),
                     answer: Localized.answer12(),
                     isExpanded: false),
        FaqCellModel(index: 13,
                     question: Localized.question13(),
                     answer: Localized.answer13(),
                     isExpanded: false),
        FaqCellModel(index: 14,
                     question: Localized.question14(),
                     answer: Localized.answer14(),
                     isExpanded: false)
    ]

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

        cell.set(model: faqs[indexPath.row],
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
        faqs[faq].isExpanded = visible
        // suppress animation to kill white flicker
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}

struct FaqCellModel {

    let index: Int
    let question: String
    let answer: String
    var isExpanded: Bool
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

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(toggleTapped))
        addGestureRecognizer(tap)
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

    func set(model: FaqCellModel,
             delegate: FaqCellDelegate) {
        self.index = model.index
        self.delegate = delegate
        questionLabel?.text = model.question
        answerLabel?.text = model.answer
        toggleButton?.isSelected = model.isExpanded
        setAnswerShown()
    }
}

private extension FaqCell {

    @IBAction func toggleTapped(_ sender: UIButton) {
        guard let button = toggleButton else { return }

        button.isSelected.toggle()
        if setAnswerShown() {
            delegate?.set(faq: self.index,
                          answer: button.isSelected)
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
