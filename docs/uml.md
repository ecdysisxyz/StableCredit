# Main Bundle
## ER図
```mermaid
erDiagram
    GlobalState {
        bool initialized
        string name
        string symbol
        uint8 decimals
        address governanceTokenAddress
        uint256 feeRate
        uint256 lastGoodPrice
        uint256 MINIMUM_COLLATERALIZATION_RATIO
        uint256 totalCreditScore
        uint256 lendingPool
        uint256 totalSupply
        uint256 loanCounter
        uint256 mintProposalCounter
    }
    User {
        address userAddress
        bool isFrozen
        bool isActive
        bool isStaked
        uint256 creditScore
        bool repaidWithinYear
        uint256 repaidAmount
    }
    LoanApplication {
        uint loanID
        address borrower
        uint256 amount
        string status
        uint256 fee
        uint256 totalVotes
        uint256 voteCount
    }
    MintProposal {
        uint proposalID
        address proposer
        uint256 amount
        uint256 votesFor
        uint256 votesAgainst
        bool executed
    }
    Transaction {
        uint transactionID
        address sender
        address receiver
        uint256 amount
        uint256 timestamp
    }
    FreezeProposal {
        uint proposalID
        address proposedUser
        address proposer
        uint256 startTime
        uint256 endTime
        uint256 totalVotes
        uint256 voteCount
        bool isApproved
    }
    UnfreezeProposal {
        uint proposalID
        address proposedUser
        address proposer
        uint256 startTime
        uint256 endTime
        uint256 totalVotes
        uint256 voteCount
        bool isApproved
    }
    LoanVote {
        address voter
        uint loanID
        bool voted
    }
    Allowance {
        address owner
        address spender
        uint256 amount
    }
    UserLoanApplications {
        address userAddress
        uint256 loanApplicationID
    }
    UserTransactions {
        address userAddress
        uint256 transactionID
    }
    MintProposalVoters {
        uint proposalID
        address voter
        bool voted
    }

    GlobalState ||--o{ User : "users"
    GlobalState ||--o{ LoanApplication : "loanApplications"
    GlobalState ||--o{ MintProposal : "mintProposals"
    GlobalState ||--o{ FreezeProposal : "freezeProposals"
    GlobalState ||--o{ UnfreezeProposal : "unfreezeProposals"
    User ||--o{ UserLoanApplications : "loanApplicationIDs"
    User ||--o{ UserTransactions : "transactionIDs"
    LoanApplication ||--o{ LoanVote : "loanVotes"
    MintProposal ||--o{ MintProposalVoters : "voters"
    User ||--o{ Allowance : "allowances"
    Transaction
```


## CDPOperations.sol Functions Flowcharts
```
flowchart TD
    A[deposit] --> B{amount > 0?}
    B -- Yes --> C{msg.value == amount?}
    C -- Yes --> D[gs.balances＿_user__ += amount]
    D --> E[gs.totalSupply += amount]
    E --> F[_updatePriorityRegistry＿_user__]
    C -- No --> G[Revert with __Incorrect amount of ETH sent__]
    B -- No --> H[Revert with __Invalid amount__]

    subgraph CDPOperations
        A
        B
        C
        D
        E
        F
        G
        H
    end

    I[borrow] --> J{amount > 0?}
    J -- Yes --> K{gs.users＿_borrower__.isActive?}
    K -- Yes --> L{msg.value > 0?}
    L -- Yes --> M[ethPrice = PriceConsumer__address__this____.getLatestPrice____]
    M --> N{ethPrice > 0?}
    N -- Yes --> O[Calculate collateral and maxBorrow]
    O --> P{amount <= maxBorrow?}
    P -- Yes --> Q[gs.balances＿_borrower__ += amount]
    Q --> R[Calculate and deduct fee]
    R --> S[Update CDP]
    S --> T[_updatePriorityRegistry＿_borrower__]
    P -- No --> U[Revert with __Insufficient collateral__]
    N -- No --> V[Revert with __Invalid price__]
    L -- No --> W[Revert with __Insufficient collateral__]
    K -- No --> X[Revert with __User is not active__]
    J -- No --> Y[Revert with __Invalid amount__]

    subgraph CDPOperations
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
        V
        W
        X
        Y
    end

    Z[repay] --> AA{amount > 0?}
    AA -- Yes --> AB{gs.balances＿_borrower__ >= amount?}
    AB -- Yes --> AC[gs.balances＿_borrower__ -= amount]
    AC --> AD[gs.totalSupply -= amount]
    AD --> AE[gs.cdps＿_borrower__.debt -= amount]
    AE --> AF[Calculate and add reward]
    AF --> AG[_updatePriorityRegistry＿_borrower__]
    AB -- No --> AH[Revert with __Insufficient balance__]
    AA -- No --> AI[Revert with __Invalid amount__]

    subgraph CDPOperations
        Z
        AA
        AB
        AC
        AD
        AE
        AF
        AG
        AH
        AI
    end
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


### ERC20Functions関数のフローチャート
```mermaid
flowchart TD
    A[name] --> B[return gs.name]
    C[symbol] --> D[return gs.symbol]
    E[decimals] --> F[return gs.decimals]
    G[totalSupply] --> H[return gs.totalSupply]
    I[balanceOf] --> J[return gs.balances＿_account__]
    K[approve] --> L[gs.allowances＿_msg.sender__＿_spender__ = amount]
    L --> M[return true]
    N[allowance] --> O[return gs.allowances＿_owner__＿_spender__]
    P[transferFrom] --> Q{gs.balances＿_sender__ >= amount?}
    Q -- Yes --> R{gs.allowances＿_sender__＿_msg.sender__ >= amount?}
    R -- Yes --> S[gs.balances＿_sender__ -= amount]
    S --> T[gs.balances＿_recipient__ += amount]
    T --> U[gs.allowances＿_sender__＿_msg.sender__ -= amount]
    U --> V[Update transaction record]
    V --> W[Update user status]
    W --> X[Calculate and update credit score]
    X --> Y[return true]
    R -- No --> Z[Revert with __Allowance exceeded__]
    Q -- No --> AA[Revert with __Insufficient balance__]

    subgraph ERC20Functions
        A
        B
        C
        D
        E
        F
        G
        H
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
        V
        W
        X
        Y
        Z
        AA
    end
```

### FrozenOperations.sol flowchart
```mermaid
flowchart TD
    A[proposeFreeze] --> B{gs.users＿_msg.sender__.isStaked?}
    B -- Yes --> C{!gs.users＿_user__.isFrozen?}
    C -- Yes --> D[Create freeze proposal]
    D --> E[Increment freezeProposalCounter]
    C -- No --> F[Revert with __User is already frozen__]
    B -- No --> G[Revert with __Only staked users can propose freeze__]

    subgraph FrozenOperations
        A
        B
        C
        D
        E
        F
        G
    end

    H[voteOnFreeze] --> I{proposal.proposalID == proposalID?}
    I -- Yes --> J{gs.users＿_msg.sender__.isStaked?}
    J -- Yes --> K{!gs.freezeVotes＿_proposalID__＿_msg.sender__?}
    K -- Yes --> L[gs.freezeVotes＿_proposalID__＿_msg.sender__ = true]
    L --> M[proposal.totalVotes += governanceToken.stakedBalanceOf__msg.sender__]
    M --> N[proposal.voteCount++]
    N --> O{proposal.totalVotes > __gs.totalSupply / 2__?}
    O -- Yes --> P[proposal.isApproved = true]
    P --> Q[gs.users＿_proposal.proposedUser__.isFrozen = true]
    Q --> R[Reduce credit scores of users who transacted with frozen user]
    O -- No --> S[Continue]
    K -- No --> T[Revert with __Already voted__]
    J -- No --> U[Revert with __Only staked users can vote__]
    I -- No --> V[Revert with __Invalid proposal ID__]

    subgraph FrozenOperations
        H
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
        V
    end

    W[proposeUnfreeze] --> X{gs.users＿_user__.isFrozen?}
    X -- Yes --> Y[Create unfreeze proposal]
    Y --> Z[Increment unfreezeProposalCounter]
    X -- No --> AA[Revert with __User is not frozen__]

    subgraph FrozenOperations
        W
        X
        Y
        Z
        AA
    end

    BB[voteOnUnfreeze] --> CC{proposal.proposalID == proposalID?}
    CC -- Yes --> DD{gs.users＿_msg.sender__.isStaked?}
    DD -- Yes --> EE{!gs.unfreezeVotes＿_proposalID__＿_msg.sender__?}
    EE -- Yes --> FF[gs.unfreezeVotes＿_proposalID__＿_msg.sender__ = true]
    FF --> GG[proposal.totalVotes += gs.users＿_msg.sender__.governanceTokensStaked]
    GG --> HH[proposal.voteCount++]
    HH --> II{proposal.totalVotes > __gs.totalSupply / 2__?}
    II -- Yes --> JJ[proposal.isApproved = true]
    JJ --> KK[gs.users＿_proposal.proposedUser__.isFrozen = false]
    II -- No --> LL[Continue]
    EE -- No --> MM[Revert with __Already voted__]
    DD -- No --> NN[Revert with __Only staked users can vote__]
    CC -- No --> OO[Revert with __Invalid proposal ID__]

    subgraph FrozenOperations
        BB
        CC
        DD
        EE
        FF
        GG
        HH
        II
        JJ
        KK
        LL
        MM
        NN
        OO
    end

```


### Lend.solの関数群のフローチャート
```mermaid
flowchart TD
    A[proposeMint] --> B{amount > 0?}
    B -- Yes --> C{gs.governanceTokenAddress != address__0__?}
    C -- Yes --> D[Create mint proposal]
    D --> E[Increment mintProposalCounter]
    C -- No --> F[Revert with __Governance token not set__]
    B -- No --> G[Revert with __Invalid amount__]

    subgraph Lend
        A
        B
        C
        D
        E
        F
        G
    end

    H[mintVote] --> I{proposalID < gs.mintProposalCounter?}
    I -- Yes --> J{!proposal.executed?}
    J -- Yes --> K{!proposal.voters＿_msg.sender__?}
    K -- Yes --> L{votingPower > 0?}
    L -- Yes --> M{support?}
    M -- Yes --> N[proposal.votesFor += votingPower]
    M -- No --> O[proposal.votesAgainst += votingPower]
    N --> P[proposal.voters＿_msg.sender__ = true]
    O --> P
    P --> Q[Emit MintVoteCast event]
    L -- No --> R[Revert with __No voting power__]
    K -- No --> S[Revert with __Already voted__]
    J -- No --> T[Revert with __Proposal already executed__]
    I -- No --> U[Revert with __Invalid proposal ID__]

    subgraph Lend
        H
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
    end

    V[tallyMintVotes] --> W{proposalID < gs.mintProposalCounter?}
    W -- Yes --> X{!proposal.executed?}
    X -- Yes --> Y{totalVotes > 0?}
    Y -- Yes --> Z{proposal.votesFor > proposal.votesAgainst?}
    Z -- Yes --> AA[_mintNewGovernanceTokens__proposal.amount__]
    AA --> AB[proposal.executed = true]
    AB --> AC[Emit MintProposalExecuted event]
    Z -- No --> AD[proposal.executed = true]
    AD --> AE[Emit MintProposalRejected event]
    Y -- No --> AF[Revert with __No votes cast__]
    X -- No --> AG[Revert with __Proposal already executed__]
    W -- No --> AH[Revert with __Invalid proposal ID__]

    subgraph Lend
        V
        W
        X
        Y
        Z
        AA
        AB
        AC
        AD
        AE
        AF
        AG
        AH
    end

    AI[proposeLoan] --> AJ{!gs.users＿_msg.sender__.isFrozen?}
    AJ -- Yes --> AK{amount <= userShare?}
    AK -- Yes --> AL[Create loan application]
    AL --> AM[Increment loanCounter]
    AJ -- No --> AN[Revert with __User is frozen__]
    AK -- No --> AO[Revert with __Amount exceeds user share__]

    subgraph Lend
        AI
        AJ
        AK
        AL
        AM
        AN
        AO
    end

    AP[loanVote] --> AQ{loan.loanID == loanID?}
    AQ -- Yes --> AR{!gs.users＿_msg.sender__.isFrozen?}
    AR -- Yes --> AS{msg.sender != loan.borrower?}
    AS -- Yes --> AT{totalSentAmount >= voteAmount?}
    AT -- Yes --> AU[Gather ballots]
    AU --> AV[Increment totalVotes and voteCount]
    AS -- No --> AW[Revert with __Borrower cannot vote__]
    AR -- No --> AX[Revert with __User is frozen__]
    AQ -- No --> AY[Revert with __Invalid loan ID__]
    AT -- No --> AZ[Revert with __Insufficient voting power__]

    subgraph Lend
        AP
        AQ
        AR
        AS
        AT
        AU
        AV
        AW
        AX
        AY
        AZ
    end

    BA[tallyLoanVotes] --> BB{loan.loanID == loanID?}
    BB -- Yes --> BC[Calculate total voting power]
    BC --> BD{loan.totalVotes >= requiredVotes?}
    BD -- Yes --> BE[loan.status = __Approved__]
    BD -- No --> BF[loan.status = __Rejected__]
    BE --> BG[Transfer pooled governance tokens]
    BG --> BH[gs.lendingPool -= loan.totalVotes]

    subgraph Lend
        BA
        BB
        BC
        BD
        BE
        BF
        BG
        BH
    end

    BI[repayGovernanceToken] --> BJ{loan.loanID == loanID?}
    BJ -- Yes --> BK{loan.borrower == msg.sender?}
    BK -- Yes --> BL{!gs.users＿_msg.sender__.isFrozen?}
    BL -- Yes --> BM{amount >= totalRepayAmount?}
    BM -- Yes --> BN[Check allowance]
    BN --> BO[Perform transferFrom]
    BO --> BP[loan.status = __Repaid__]
    BP --> BQ[Update repaid info]
    BQ --> BR[Calculate and add reward]
    BR --> BS[Update credit score]
    BM -- No --> BT[Revert with __Insufficient amount to cover loan and interest__]
    BL -- No --> BU[Revert with __User is frozen__]
    BK -- No --> BV[Revert with __Not the borrower__]
    BJ -- No --> BW[Revert with __Invalid loan ID__]

    subgraph Lend
        BI
        BJ
        BK
        BL
        BM
        BN
        BO
        BP
        BQ
        BR
        BS
        BT
        BU
        BV
        BW
    end
```

# Governance Bundle

## ER図
```mermaid
erDiagram
    GlobalState {
        uint totalSupply
        uint totalStaked
        bool initialized
        string name
        string symbol
        uint8 decimals
    }
    Balance {
        address userAddress
        uint balance
    }
    Allowance {
        address owner
        address spender
        uint amount
    }
    StakedBalance {
        address userAddress
        uint stakedBalance
    }
    VotingPower {
        address userAddress
        uint votingPower
    }
    Vote {
        address voter
        address proposal
        bool voted
    }

    GlobalState ||--o{ Balance : "balances"
    GlobalState ||--o{ Allowance : "allowances"
    GlobalState ||--o{ StakedBalance : "stakedBalances"
    GlobalState ||--o{ VotingPower : "votingPower"
    GlobalState ||--o{ Vote : "votes"
```

## Flowchart

### GovernanceT0ken.sol

```mermaid
flowchart TD
    A[name] --> B[return gs.name]
    C[symbol] --> D[return gs.symbol]
    E[decimals] --> F[return gs.decimals]
    G[totalSupply] --> H[return gs.totalSupply]
    I[balanceOf] --> J[return gs.balances＿_account__]
    K[approve] --> L[gs.allowances＿_msg.sender__＿_spender__ = amount]
    L --> M[return true]
    N[allowance] --> O[return gs.allowances＿_owner__＿_spender__]
    P[transferFrom] --> Q{gs.balances＿_sender__ >= amount?}
    Q -- Yes --> R{gs.allowances＿_sender__＿_msg.sender__ >= amount?}
    R -- Yes --> S[gs.balances＿_sender__ -= amount]
    S --> T[gs.balances＿_recipient__ += amount]
    T --> U[gs.allowances＿_sender__＿_msg.sender__ -= amount]
    U --> V[return true]
    R -- No --> Z[Revert with __Allowance exceeded__]
    Q -- No --> AA[Revert with __Insufficient balance__]

    subgraph GovernanceToken
        A
        B
        C
        D
        E
        F
        G
        H
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
        V
        Z
        AA
    end

    AB[transfer] --> AC{amount > 0?}
    AC -- Yes --> AD{gs.balances＿_msg.sender__ >= amount?}
    AD -- Yes --> AE[gs.balances＿_msg.sender__ -= amount]
    AE --> AF[gs.balances＿_recipient__ += amount]
    AF --> AG[return true]
    AD -- No --> AH[Revert with __Insufficient balance__]
    AC -- No --> AI[Revert with __Invalid amount__]

    subgraph GovernanceToken
        AB
        AC
        AD
        AE
        AF
        AG
        AH
        AI
    end

    AJ[stakedBalanceOf] --> AK[return gs.stakedBalances＿_account__]

    subgraph GovernanceToken
        AJ
        AK
    end
```

### Stake.sol
```mermaid
flowchart TD
    A[stakeTokens] --> B{amount > 0?}
    B -- Yes --> C{gs.balances＿_msg.sender__ >= amount?}
    C -- Yes --> D[gs.balances＿_msg.sender__ -= amount]
    D --> E[Create new stake]
    E --> F[Increment stakeCounter]
    E --> G[gs.stakedBalances＿_msg.sender__ += amount]
    C -- No --> H[Revert with __Insufficient balance__]
    B -- No --> I[Revert with __Invalid amount__]

    subgraph Stake
        A
        B
        C
        D
        E
        F
        G
        H
        I
    end

    J[withdrawStake] --> K{stake.stakeID == stakeID?}
    K -- Yes --> L{stake.staker == msg.sender?}
    L -- Yes --> M{!stake.isWithdrawn?}
    M -- Yes --> N{block.timestamp >= stake.endTime?}
    N -- Yes --> O[stake.isWithdrawn = true]
    O --> P[gs.balances＿_msg.sender__ += stake.amount]
    P --> Q[gs.stakedBalances＿_msg.sender__ -= stake.amount]
    N -- No --> R[Revert with __Stake period not ended__]
    M -- No --> S[Revert with __Already withdrawn__]
    L -- No --> T[Revert with __Not the staker__]
    K -- No --> U[Revert with __Invalid stake ID__]

    subgraph Stake
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
    end
```