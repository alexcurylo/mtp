// @copyright Trollwerks Inc.

import UIKit

protocol FaqCellDelegate: AnyObject {

    func set(faq: Int, answer visible: Bool)
}

/// Display the website FAQ as a collapsible table
final class FaqVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.faqVC

    @IBOutlet private var backgroundView: UIView?

    private var faqs: [FaqCellModel] = [
        FaqCellModel(index: 0,
                     question: L.question0(),
                     answer: L.answer0(),
                     isExpanded: false),
        FaqCellModel(index: 1,
                     question: L.question1(),
                     answer: L.answer1(),
                     isExpanded: false),
        FaqCellModel(index: 2,
                     question: L.question2(),
                     answer: L.answer2(),
                     isExpanded: false),
        FaqCellModel(index: 3,
                     question: L.question3(),
                     answer: L.answer3(),
                     isExpanded: false),
        FaqCellModel(index: 4,
                     question: L.question4(),
                     answer: L.answer4(),
                     isExpanded: false),
        FaqCellModel(index: 5,
                     question: L.question5(),
                     answer: L.answer5(),
                     isExpanded: false),
        FaqCellModel(index: 6,
                     question: L.question6(),
                     answer: L.answer6(),
                     isExpanded: false),
        FaqCellModel(index: 7,
                     question: L.question7(),
                     answer: L.answer7(),
                     isExpanded: false),
        FaqCellModel(index: 8,
                     question: L.question8(),
                     answer: L.answer8(),
                     isExpanded: false),
        FaqCellModel(index: 9,
                     question: L.question9(),
                     answer: L.answer9(),
                     isExpanded: false),
        FaqCellModel(index: 10,
                     question: L.question10(),
                     answer: L.answer10(),
                     isExpanded: false),
        FaqCellModel(index: 11,
                     question: L.question11(),
                     answer: L.answer11(),
                     isExpanded: false),
        FaqCellModel(index: 12,
                     question: L.question12(),
                     answer: L.answer12(),
                     isExpanded: false),
        FaqCellModel(index: 13,
                     question: L.question13(),
                     answer: L.answer13(),
                     isExpanded: false),
        FaqCellModel(index: 14,
                     question: L.question14(),
                     answer: L.answer14(),
                     isExpanded: false)
    ]

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: FaqCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.faqCell,
            for: indexPath)

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

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        backgroundView.require()
    }
}

// MARK: - FaqCellDelegate

extension FaqVC: FaqCellDelegate {

    func set(faq: Int, answer visible: Bool) {
        faqs[faq].isExpanded = visible

        tableView.update()
    }
}

struct FaqCellModel {

    let index: Int
    let question: String
    let answer: String
    var isExpanded: Bool
}

final class FaqCell: UITableViewCell {

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
        super.prepareForReuse()

        index = 0
        delegate = nil
        questionLabel?.text = nil
        answerLabel?.text = nil
        toggleButton?.isSelected = false
        setAnswerShown()
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
