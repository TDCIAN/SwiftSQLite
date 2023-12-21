//
//  MemoViewController.swift
//  SwiftSQLite
//
//  Created by 김정민 on 12/20/23.
//

import UIKit
import SnapKit

final class MemoViewController: UIViewController {

    private lazy var memoTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.register(MemoTableViewCell.self, forCellReuseIdentifier: MemoTableViewCell.className)
        return tableView
    }()
    
    let viewModel = MemoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setup()
        self.viewModel.refreshMemos {
            self.memoTableView.reloadData()
        }
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "Memos"
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
    
    @objc private func addMemo() {
        let alertController = UIAlertController(title: "Add new memo", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Input title"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Input content"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alertController.textFields?[0].text,
                  let content = alertController.textFields?[1].text
            else { return }
            self.viewModel.insertMemo(title: title, content: content)
            self.viewModel.refreshMemos {
                self.memoTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func showUpdateMemoAlert(_ memo: Memo) {
        let alertController = UIAlertController(title: "Edit memo", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Input title"
            textField.text = memo.title
        }
        alertController.addTextField { textField in
            textField.placeholder = "Input content"
            textField.text = memo.content
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alertController.textFields?[0].text,
                  let content = alertController.textFields?[1].text
            else { return }
            let newMemo = Memo(
                id: memo.id,
                title: title,
                content: content
            )
            self.viewModel.updateMemo(newMemo)
            self.viewModel.refreshMemos {
                self.memoTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}

extension MemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MemoTableViewCell.className,
            for: indexPath
        ) as? MemoTableViewCell else { return UITableViewCell() }
        let memo = self.viewModel.memos[indexPath.item]
        
        cell.setMemo(with: memo)
        
        return cell
    }
}

extension MemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let memo = self.viewModel.memos[indexPath.item]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            self.viewModel.deleteMemo(memo: memo)
            self.viewModel.refreshMemos {
                self.memoTableView.reloadData()
            }
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            self.showUpdateMemoAlert(memo)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemGray3
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
}

extension UIView {
    class var className: String {
        return String(describing: self)
    }
}
