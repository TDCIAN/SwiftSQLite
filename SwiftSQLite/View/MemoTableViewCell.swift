//
//  MemoTableViewCell.swift
//  SwiftSQLite
//
//  Created by 김정민 on 12/21/23.
//

import UIKit
import SnapKit

final class MemoTableViewCell: UITableViewCell {
    
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
