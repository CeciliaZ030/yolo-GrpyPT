const { OpenAI } = require('openai');
const { fetchContractABI } = require('./abiService');
const { ethers } = require('ethers');

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Process user intent from natural language to transaction package
 * @param {string} message - User's natural language message
 * @param {string} walletAddress - User's wallet address
 * @returns {Promise<Object>} Transaction package
 */
async function processUserIntent(message, walletAddress) {
  try {
    // 1. Parse the user's intent using LLM
    const intent = await parseUserIntent(message);
    
    // 2. Gather required ABIs and contract information
    const steps = await buildTransactionSteps(intent, walletAddress);
    
    // 3. Generate gas estimates
    const gasEstimate = await estimateGas(steps, walletAddress);
    
    // 4. Build the final transaction package
    return {
      id: generateId(),
      summary: intent.summary,
      explanation: intent.explanation,
      steps: steps,
      estimatedGasETH: gasEstimate.eth,
      estimatedGasUSD: gasEstimate.usd
    };
  } catch (error) {
    console.error('Error processing user intent:', error);
    throw error;
  }
}

/**
 * Parse user intent using LLM
 * @param {string} message - User message
 * @returns {Promise<Object>} Parsed intent
 */
async function parseUserIntent(message) {
  // Using OpenAI to parse the intent
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: `You are an AI assistant that interprets crypto-related natural language commands and converts them to structured intents.
        Parse the user's crypto command into a structured format that can be used to generate blockchain transactions.
        Return a JSON object with the following structure:
        {
          "action": "swap|transfer|approve|stake|unstake|etc",
          "summary": "Brief one-line summary of what the user wants to do",
          "explanation": "Detailed but concise explanation of what will happen",
          "parameters": {
            // Action-specific parameters like token addresses, amounts, etc.
          }
        }`
      },
      {
        role: 'user',
        content: message
      }
    ],
    response_format: { type: 'json_object' }
  });
  
  try {
    const content = response.choices[0].message.content;
    return JSON.parse(content);
  } catch (error) {
    console.error('Error parsing LLM response:', error);
    throw new Error('Failed to understand the request');
  }
}

/**
 * Build transaction steps from parsed intent
 * @param {Object} intent - Parsed user intent
 * @param {string} walletAddress - User's wallet address
 * @returns {Promise<Array>} Array of transaction steps
 */
async function buildTransactionSteps(intent, walletAddress) {
  // This is where we'd determine what contracts to interact with
  // and what functions to call based on the intent
  
  // For demo purposes, we'll return some example steps based on common intents
  const steps = [];
  
  switch (intent.action.toLowerCase()) {
    case 'swap':
      // Example: Swapping ETH for USDC on Uniswap
      steps.push({
        id: generateId(),
        order: 1,
        title: 'Approve Uniswap Router',
        explanation: 'First, we need to allow Uniswap to access your tokens for the swap.',
        contractAddress: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
        functionName: 'approve',
        parameters: [
          {
            id: generateId(),
            name: 'spender',
            value: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D', // Uniswap V2 Router
            type: 'address'
          },
          {
            id: generateId(),
            name: 'amount',
            value: ethers.parseEther(intent.parameters.amount || '0.1').toString(),
            type: 'uint256'
          }
        ],
        isExpanded: false
      });
      
      steps.push({
        id: generateId(),
        order: 2,
        title: 'Execute Swap',
        explanation: "Now, we'll execute the swap through Uniswap.",
        contractAddress: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D', // Uniswap V2 Router
        functionName: 'swapExactETHForTokens',
        parameters: [
          {
            id: generateId(),
            name: 'amountOutMin',
            value: '0', // In a real app, we'd calculate this based on price impact
            type: 'uint256'
          },
          {
            id: generateId(),
            name: 'path',
            value: '[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48]',
            type: 'address[]'
          },
          {
            id: generateId(),
            name: 'to',
            value: walletAddress,
            type: 'address'
          },
          {
            id: generateId(),
            name: 'deadline',
            value: Math.floor(Date.now() / 1000) + 3600, // 1 hour from now
            type: 'uint256'
          }
        ],
        isExpanded: false
      });
      break;
      
    case 'transfer':
      // Example: Transferring tokens
      steps.push({
        id: generateId(),
        order: 1,
        title: 'Transfer Tokens',
        explanation: 'Send tokens to the recipient address.',
        contractAddress: intent.parameters.tokenAddress || '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // Default to USDC
        functionName: 'transfer',
        parameters: [
          {
            id: generateId(),
            name: 'recipient',
            value: intent.parameters.to || '0x0000000000000000000000000000000000000000',
            type: 'address'
          },
          {
            id: generateId(),
            name: 'amount',
            value: intent.parameters.amount || '0',
            type: 'uint256'
          }
        ],
        isExpanded: false
      });
      break;
      
    // Add more cases for other actions
      
    default:
      throw new Error(`Unsupported action: ${intent.action}`);
  }
  
  return steps;
}

/**
 * Estimate gas for transaction steps
 * @param {Array} steps - Transaction steps
 * @param {string} walletAddress - User's wallet address
 * @returns {Promise<Object>} ETH and USD gas estimates
 */
async function estimateGas(steps, walletAddress) {
  // In a real app, we would use the Ethereum provider to estimate gas
  // For demo purposes, we'll return a fixed estimate
  return {
    eth: '0.003',
    usd: 9.45
  };
}

/**
 * Generate a random ID
 * @returns {string} UUID
 */
function generateId() {
  return 'id_' + Math.random().toString(36).substr(2, 9);
}

module.exports = {
  processUserIntent
}; 