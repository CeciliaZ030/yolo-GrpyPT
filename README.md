# YoloGrpyPT

An AI-driven chat application that also functions as a crypto wallet.  
Users can issue natural language commands (e.g., "withdraw ETH from Lido, swap to USDC on Uniswap") and the system:
- Dynamically fetches smart contract ABIs,
- Generates **on-chain HTTP call packages**,
- Explains each step clearly,
- Lets users **approve via Face ID**,
- Signs transactions **locally** using the crypto key stored in **Apple Keychain**.

## Getting Started

### Prerequisites

- Node.js v16+ for the backend
- Xcode 14.0+ for iOS development
- API keys for:
  - Ethereum RPC (Infura/Alchemy)
  - OpenAI or Anthropic (for LLM)
  - Etherscan (for fetching ABIs)

### Installation

#### Backend

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/yolo-GrpyPT.git
   cd yolo-GrpyPT
   ```

2. Install backend dependencies:
   ```bash
   cd Backend
   npm install
   ```

3. Create a `.env` file based on `.env.example`:
   ```
   PORT=3000
   INFURA_API_KEY=your_infura_api_key
   OPENAI_API_KEY=your_openai_api_key
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

4. Start the backend:
   ```bash
   npm run dev
   ```

#### iOS App

1. Open YoloApp in Xcode:
   ```bash
   cd YoloApp
   open Package.swift
   ```

2. Update the API endpoint in `YoloApp/Sources/YoloApp/APIClient.swift` to point to your backend.

3. Run the app in the simulator or on a physical device.

## Project Structure

- **Backend/** - Node.js backend server
  - **src/** - Source code
    - **services/** - Backend services (intent processing, ABI fetching)
    - **index.js** - Main entry point

- **YoloApp/** - Swift package for iOS app
  - **Sources/** - App source code
    - **Models/** - Data models
    - **ViewModels/** - View models
    - **Views/** - SwiftUI views

## How It Works

1. The user types a command into the app chat interface.
2. The command is sent to the backend, which uses LLMs to interpret the intent.
3. The backend fetches necessary contract ABIs and prepares a transaction package.
4. The transaction package is sent back to the app for user review.
5. After user approval via Face ID, the transaction is signed locally and submitted to the blockchain.

## Overview
An AI-driven chat application that also functions as a crypto wallet.  
Users can issue natural language commands (e.g., "withdraw ETH from Lido, swap to USDC on Uniswap") and the system:
- Dynamically fetches smart contract ABIs,
- Generates **on-chain HTTP call packages**,
- Explains each step clearly,
- Lets users **approve via Face ID**,
- Signs transactions **locally** using the crypto key stored in **Apple Keychain**.

---

## Major Components

### 1. Frontend
- **Platform**: iOS App (SwiftUI)
- **Core Screens**:
  - Chat Interface
  - Transaction Review Modal (show calls + explanations)
  - Face ID Authentication Prompt
  - Transaction History and Status
- **Core Features**:
  - Natural language chat with AI
  - Transaction preview (technical + friendly explanation)
  - Face ID for signing approval
  - Push notifications for transaction updates

### 2. Backend (MCP Server)
- **Responsibilities**:
  - Parse user intents (leveraging LLMs via API calls)
  - Fetch smart contract ABIs from the web (Etherscan, Sourcify, etc.)
  - Generate HTTP-based smart contract call payloads
  - Estimate gas costs if needed
  - Produce human-readable explanations of each call
  - Return full transaction packages to the frontend for review

- **Smart Contract Interaction**:
  - Dynamic ABI pulling and caching
  - Read/write operation construction
  - Optional: dry-run/simulate transactions (for safety previews)

### 3. Wallet Engine
- **Private Key Storage**:
  - Crypto key stored securely in Apple Keychain / Secure Enclave
- **Signing Process**:
  - User must authenticate via Face ID
  - Signing happens **locally** on device (never exposing private key)
  - Signed transactions sent to blockchain via standard RPC endpoints (Infura, Alchemy, etc.)

---

## Application Flow

1. User types a command into chat.
2. Frontend sends the text to backend MCP.
3. MCP processes:
   - Calls ChatGPT-4o / Claude 3.8 to interpret intent.
   - Fetches contract ABIs.
   - Prepares sequence of HTTP contract calls + explanations.
4. Backend sends the transaction plan to the app.
5. User reviews each step and approves.
6. App triggers Face ID for signing.
7. Transactions are signed and sent on-chain.
8. App updates user with transaction status and receipts.

---

## Tech Stack

| Part                | Technology                                  |
|---------------------|---------------------------------------------|
| Frontend (iOS App)   | SwiftUI, Combine                            |
| Backend (MCP Server) | Node.js                                     |
| LLM Provider         | OpenAI API (ChatGPT-4o) or Anthropic API (Claude 3.8) |
| Blockchain RPC       | Infura, Alchemy, or custom full node        |
| ABI Fetching         | Etherscan API, Sourcify, 4byte.directory    |
| Secure Storage       | Apple Keychain, Secure Enclave             |
| Face ID              | Apple LocalAuthentication Framework        |

---

## Security Highlights
- **Face ID** required for every transaction approval.
- **Local signing** only, private keys never transmitted.
- **ABI validation** from trusted sources.
- Potential **phishing detection** or **transaction simulation** to protect users.
