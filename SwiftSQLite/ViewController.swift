//
//  ViewController.swift
//  SwiftSQLite
//
//  Created by 김정민 on 12/20/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private lazy var memoTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemYellow
        tableView.register(MemoCell.self, forCellReuseIdentifier: MemoCell.className)
        return tableView
    }()

    let databaseManager = DatabaseManager()
    var memos: [Memo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setup()
        self.initDatabase()
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "메모 목록"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(self.addMemo)
        )
    }
    private func setup() {
        self.view.addSubview(self.memoTableView)
        self.memoTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func initDatabase() {
        self.memos = databaseManager.retrieveMemos()
    }
    
    @objc private func addMemo() {
        // 새로운 메모 추가
        let alertController = UIAlertController(title: "새로운 메모 추가", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "제목을 입력하세요"
        }
        alertController.addTextField { textField in
            textField.placeholder = "내용을 입력하세요"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { _ in
            guard let title = alertController.textFields?[0].text,
                  let content = alertController.textFields?[1].text
            else { return }
            self.databaseManager.insertMemo(title: title, content: content)
            self.memos = self.databaseManager.retrieveMemos()
            self.memoTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MemoCell.className,
            for: indexPath
        ) as? MemoCell else { return UITableViewCell() }
        let memo = self.memos[indexPath.item]
        cell.setMemo(with: memo)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//    }
}

final class MemoCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contentLabel)
        
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.contentLabel.snp.top).offset(-8)
        }
        
        self.contentLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func setMemo(with memo: Memo) {
        self.titleLabel.text = memo.title
        self.contentLabel.text = memo.content
    }
}

extension UIView {
    class var className: String {
        return String(describing: self)
    }
}

struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}

import SwiftUI

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
            let viewController: UIViewController

            func makeUIViewController(context: Context) -> UIViewController {
                return viewController
            }

            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            }
        }

        func toPreview() -> some View {
            Preview(viewController: self)
        }
}
#endif
