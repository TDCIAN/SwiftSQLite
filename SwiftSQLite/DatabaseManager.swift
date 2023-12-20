//
//  DatabaseManager.swift
//  SwiftSQLite
//
//  Created by 김정민 on 12/20/23.
//

import Foundation
import SQLite3

class DatabaseManager {
    var db: OpaquePointer?
    
    init() {
        // 데이터베이스 경로 설정
        let fileURL = try! FileManager.default.url(
            for: .documentDirectory, 
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("myDatabase.sqlite")
        
        // 데이터베이스 열기
        if sqlite3_open(fileURL.path(percentEncoded: true), &self.db) == SQLITE_OK {
            print("Successfully opened database")
            // 테이블 생성
            self.createMemoTable()
        } else {
            print("Error opening database")
        }
    }
    
    deinit {
        // 데이터베이스 닫기
        if sqlite3_close(self.db) == SQLITE_OK {
            print("Successfully closed database")
        } else {
            print("Error closing database")
        }
    }
    
    func createMemoTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS memos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, createTableQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Creating table has been successfully done, db: \(String(describing: self.db))")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
                print("Error creating table: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
            print("Error creating table: \(errorMessage)")
        }
    }
    
    func insertMemo(title: String, content: String) {
        let insertQuery = """
        INSERT INTO memos (id,title,content) VALUES (?,?,?);
        """

        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 2, NSString(string: title).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, NSString(string: content).utf8String, -1, nil)
            print("인서트 - 타이틀: \(title), 콘텐트: \(content)")
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Inserted memo successfully")
            } else {
                print("Error inserting. memo")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
            print("Error prepairing insert statement: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }
    
    func retrieveMemos() -> [Memo] {
        var memos: [Memo] = []
        let selectQuery = """
        SELECT * FROM memos;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(self.db, selectQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let content = String(cString: sqlite3_column_text(statement, 2))
                let memo = Memo(id: id, title: title, content: content)
                memos.append(memo)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
            print("Error prepairing select statement: \(errorMessage)")
        }
        sqlite3_finalize(statement)
        
        return memos
    }
    
    func updateMemo(id: Int, title: String, content: String) {
        let updateQuery = """
        UPDATE memos SET title = '\(title)', content = '\(content)' WHERE id == \(id);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(self.db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, title, -1, nil)
            sqlite3_bind_text(statement, 2, content, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Updated memo successfully")
            } else {
                print("Error updating memo")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
            print("Error preparing update statement: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }
    
    func deleteMemo(id: Int) {
        let deleteQuery = """
        DELETE FROM memos WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting memo")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db)!)
            print("Error preparing delete statement: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }
}
