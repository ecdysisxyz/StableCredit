## ER図
```mermaid
erDiagram
    User {
        address userID PK
        uint creditScore
        bool isActive
        bool isFrozen
        bool isStaked
        uint governanceTokensStaked
        uint[] loanApplicationIDs
        uint[] transactionIDs
    }
    LoanApplication {
        uint loanID PK
        address borrower FK
        uint amount
        string status
        uint fee
    }
    Transaction {
        uint transactionID PK
        address sender
        address receiver
        uint amount
        uint timestamp
    }
    StableCoin {
        uint totalSupply
        mapping(address _ uint) balances
    }
    GovernanceToken {
        uint totalSupply
        mapping(address _ uint) balances
        mapping(address _ uint) stakedBalances
        mapping(address _ uint) votingPower
        mapping(address _ mapping(address _ bool)) votes
    }
    FreezeProposal {
        uint proposalID PK
        address proposedUser FK
        address proposer FK
        uint startTime
        uint endTime
        bool isApproved
    }
    UnfreezeProposal {
        uint proposalID PK
        address proposedUser FK
        address proposer FK
        uint startTime
        uint endTime
        bool isApproved
    }
    User ||--o{ LoanApplication : submits
    User ||--o{ Transaction : initiates
    User ||--o{ Transaction : receives
    User ||--o{ StableCoin : owns
    User ||--o{ GovernanceToken : owns
    User ||--o{ FreezeProposal : proposes
    User ||--o{ UnfreezeProposal : proposes
```
## フローチャート
### issueStableCoin関数のフローチャート
```mermaid
flowchart TD
    A[issueStableCoin関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[担保の承認確認_approve]
    C --> D[担保の許可確認_allowance]
    D --> E[担保の転送_transferFrom]
    E --> F[引数のバリデーション]
    F --> G[ユーザーの状態確認_isActive]
    G --> H[ステーブルコインの発行]
    H --> I[ユーザーのステーブルコイン残高更新]
    I --> J[ガバナンストークンのfee分配]
    J --> K[処理完了]
```
### transfer関数のフローチャート
```mermaid
flowchart TD
    A[transfer関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[送金額の検証]
    C --> D[送金元の残高確認]
    D --> E[送金先の残高確認]
    E --> F[送金処理_transfer]
    F --> G[与信値の計算]
    G --> H[トランザクション情報の記録]
    H --> I[ユーザーの状態更新_isActive]
    I --> J[処理完了]
    C -->|送金額が無効| K[エラー処理]
```
### submitLoanApplication関数のフローチャート
```mermaid
flowchart TD
    A[submitLoanApplication関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[引数のバリデーション]
    C --> D[ユーザーの状態確認_isFrozen]
    D --> E[新しいLoanApplicationの作成]
    E --> F[LoanApplication情報の記録]
    F --> G[処理完了]
    D -->|ユーザーがfrozen| H[エラー処理]
```
### voteToFreezeUser関数のフローチャート
```mermaid
flowchart TD
    A[voteToFreezeUser関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[引数のバリデーション]
    C --> D[ステーク状況の確認_isStaked]
    D --> E[投票情報の記録]
    E --> F[投票数の確認]
    F -->|51%以上| G[ユーザーをfreeze状態に設定]
    G --> H[関係するユーザーの与信値減少]
    H --> I[処理完了]
    F -->|51%未満| J[処理完了]
    D -->|未ステーク| K[エラー処理]
```
### freezeUser関数のフローチャート
```mermaid
flowchart TD
    A[freezeUser関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[対象ユーザーの状態確認_isFrozen]
    C --> D[対象ユーザーをfreeze状態に設定]
    D --> E[関係するユーザーの与信値減少]
    E --> F[処理完了]
    C -->|既にfrozen| G[エラー処理]
```
### unfreezeUser関数のフローチャート
```mermaid
flowchart TD
    A[unfreezeUser関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[対象ユーザーの状態確認_isFrozen]
    C --> D[対象ユーザーをunfreeze状態に設定]
    D --> E[処理完了]
    C -->|未frozen| F[エラー処理]
```
