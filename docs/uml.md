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
    Stake {
        uint stakeID PK
        address staker FK
        uint amount
        uint startTime
        uint endTime
        bool isWithdrawn
    }
    User ||--o{ LoanApplication : submits
    User ||--o{ Transaction : initiates
    User ||--o{ Transaction : receives
    User ||--o{ StableCoin : owns
    User ||--o{ GovernanceToken : owns
    User ||--o{ FreezeProposal : proposes
    User ||--o{ UnfreezeProposal : proposes
    User ||--o{ Stake : stakes
```

## CDPOperations.sol Functions Flowcharts

### deposit Function
```mermaid
flowchart TD
    A[deposit Function Call] --> B[Check Reentrancy Guard]
    B --> C[Validate Amount]
    C --> D[Check ETH Sent]
    D --> E[Update User Balance]
    E --> F[Update Total Supply]
    F --> G[Update Priority Registry]
    G --> H[Process Completed]
```

### borrow
```mermaid
flowchart TD
    A[borrow Function Call] --> B[Check Reentrancy Guard]
    B --> C[Validate Amount]
    C --> D[Check User Status (isActive)]
    D --> E[Transfer Collateral (ETH)]
    E --> F[Get Latest ETH Price]
    F --> G[Calculate Max Borrow Amount]
    G --> H[Validate Collateral]
    H --> I[Mint StableCoins]
    I --> J[Update CDP]
    J --> K[Update Priority Registry]
    K --> L[Process Completed]
```

### repay
```mermaid
flowchart TD
    A[repay Function Call] --> B[Check Reentrancy Guard]
    B --> C[Validate Amount]
    C --> D[Check User Balance]
    D --> E[Update User Balance]
    E --> F[Update Total Supply]
    F --> G[Update CDP]
    G --> H[Reward User]
    H --> I[Update Credit Score]
    I --> J[Update Priority Registry]
    J --> K[Process Completed]
```

### withdraw
```mermaid
flowchart TD
    A[withdraw Function Call] --> B[Check Reentrancy Guard]
    B --> C[Validate Amount]
    C --> D[Check User Balance]
    D --> E[Update User Balance]
    E --> F[Update Total Supply]
    F --> G[Transfer ETH to User]
    G --> H[Update Priority Registry]
    H --> I[Process Completed]
```

### redeem
```mermaid
flowchart TD
    A[redeem Function Call] --> B[Check Reentrancy Guard]
    B --> C[Get Latest ETH Price]
    C --> D[Initialize Remaining Amount and Total Collateral Redeemed]
    D --> E[Iterate Through Priority Registry]
    E --> F[Check Remaining Amount]
    F --> G[Get User, Debt, and Collateral]
    G --> H[Check Debt vs Remaining Amount]
    H --> I[Update CDP and Collateral Redeemed]
    I --> J[Check Remaining Amount]
    J --> K[Break Loop if Remaining Amount is Zero]
    K --> L[Transfer Collateral to Sender]
    L --> M[Process Completed]
```

### sweep
```mermaid
flowchart TD
    A[sweep Function Call] --> B[Check Reentrancy Guard]
    B --> C[Get Latest ETH Price]
    C --> D[Initialize Remaining Amount and Total Collateral Swept]
    D --> E[Iterate Through Priority Registry]
    E --> F[Check Remaining Amount]
    F --> G[Get User, Debt, and Collateral]
    G --> H[Check Debt vs Remaining Amount]
    H --> I[Update CDP and Collateral Swept]
    I --> J[Check Remaining Amount]
    J --> K[Break Loop if Remaining Amount is Zero]
    K --> L[Transfer Collateral to Sender]
    L --> M[Process Completed]
```

## PriceConsumer
### getLatestPrice
```mermaid
flowchart TD
    A[getLatestPrice Function Call] --> B[Fetch Latest Round Data from ChainLink]
    B --> C[Validate Price]
    C --> D[Convert Price to 18 Decimals]
    D --> E[Return Price]
```
### updateLastGoodPrice
```mermaid
flowchart TD
    A[updateLastGoodPrice Function Call] --> B[Get Latest ETH Price]
    B --> C[Validate Price]
    C --> D[Update Last Good Price in State]
    D --> E[Process Completed]
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

### Lend.solの関数群のフローチャート
```mermaid
flowchart TD
    A[mintNewGovernanceTokens関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[引数のバリデーション]
    C --> D[プールへのトークン配分]
    D --> E[ユーザーのバランス更新]
    E --> F[処理完了]

    A2[withdrawGovernanceTokens関数の呼び出し] --> B2[Reentrancy Guardのチェック]
    B2 --> C2[ユーザーのシェア計算]
    C2 --> D2[シェアに基づく引き出し可能額の確認]
    D2 --> E2[プールからのトークン引き出し]
    E2 --> F2[ユーザーのバランス更新]
    F2 --> G2[処理完了]

    A3[repayLoan関数の呼び出し] --> B3[Reentrancy Guardのチェック]
    B3 --> C3[ローン情報の確認]
    C3 --> D3[返済額の確認]
    D3 --> E3[ローンステータスの更新]
    E3 --> F3[報酬トークンの付与]
    F3 --> G3[ユーザーの与信値更新]
    G3 --> H3[処理完了]
```

### stakeTokens関数のフローチャート
```mermaid
flowchart TD
    A[stakeTokens関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[引数のバリデーション]
    C --> D[送金元の残高確認]
    D --> E[ステーキング処理]
    E --> F[ステーキング情報の記録]
    F --> G[ユーザーのステーキング残高更新]
    G --> H[処理完了]
    C -->|無効な引数| I[エラー処理]
    D -->|残高不足| J[エラー処理]
```

### withdrawStake関数のフローチャート
```mermaid
flowchart TD
    A[withdrawStake関数の呼び出し] --> B[Reentrancy Guardのチェック]
    B --> C[ステーキング情報の確認]
    C --> D[ステーキング期間の確認]
    D --> E[ステークの引き出し処理]
    E --> F[ユーザーのステーキング残高更新]
    F --> G[処理完了]
    C -->|無効なステークID| H[エラー処理]
    D -->|期間未終了| I[エラー処理]
```
