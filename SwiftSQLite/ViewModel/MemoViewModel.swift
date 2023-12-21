//
//  MemoViewModel.swift
//  SwiftSQLite
//
//  Created by 김정민 on 12/21/23.
//

import Foundation

final class MemoViewModel {
    
    let databaseManager = DatabaseManager()
    
    var memos: [Memo] = []

    func refreshMemos(completion: @escaping () -> Void) {
        self.memos = databaseManager.retrieveMemos()
        completion()
    }
    
    func insertMemo(title: String, content: String) {
        self.databaseManager.insertMemo(title: title, content: content)
    }
    
    func updateMemo(_ newMemo: Memo) {
        self.databaseManager.updateMemo(newMemo)
    }
    
    func deleteMemo(memo: Memo) {
        self.databaseManager.deleteMemo(id: memo.id)
    }
}
