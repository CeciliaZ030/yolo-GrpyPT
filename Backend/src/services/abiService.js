const axios = require('axios');

// In-memory cache for ABIs to reduce API calls
const abiCache = new Map();

/**
 * Fetch ABI for a contract address
 * @param {string} contractAddress - Ethereum contract address
 * @returns {Promise<Array|null>} Contract ABI or null if not found
 */
async function fetchContractABI(contractAddress) {
  // Check cache first
  if (abiCache.has(contractAddress)) {
    return abiCache.get(contractAddress);
  }
  
  try {
    // Try Etherscan first
    const etherscanABI = await fetchFromEtherscan(contractAddress);
    if (etherscanABI) {
      abiCache.set(contractAddress, etherscanABI);
      return etherscanABI;
    }
    
    // Try Sourcify as a fallback
    const sourcifyABI = await fetchFromSourcify(contractAddress);
    if (sourcifyABI) {
      abiCache.set(contractAddress, sourcifyABI);
      return sourcifyABI;
    }
    
    // If all methods fail, return null
    return null;
  } catch (error) {
    console.error(`Error fetching ABI for ${contractAddress}:`, error);
    return null;
  }
}

/**
 * Fetch ABI from Etherscan
 * @param {string} contractAddress - Ethereum contract address
 * @returns {Promise<Array|null>} Contract ABI or null if not found
 */
async function fetchFromEtherscan(contractAddress) {
  try {
    const apiKey = process.env.ETHERSCAN_API_KEY;
    if (!apiKey) {
      console.warn('ETHERSCAN_API_KEY not configured');
      return null;
    }
    
    const url = `https://api.etherscan.io/api?module=contract&action=getabi&address=${contractAddress}&apikey=${apiKey}`;
    const response = await axios.get(url);
    
    if (response.data.status === '1' && response.data.result) {
      return JSON.parse(response.data.result);
    }
    
    return null;
  } catch (error) {
    console.error('Etherscan API error:', error);
    return null;
  }
}

/**
 * Fetch ABI from Sourcify
 * @param {string} contractAddress - Ethereum contract address
 * @returns {Promise<Array|null>} Contract ABI or null if not found
 */
async function fetchFromSourcify(contractAddress) {
  try {
    const url = `https://sourcify.dev/server/repository/contracts/full_match/${process.env.ETHEREUM_NETWORK || 'mainnet'}/${contractAddress}/metadata.json`;
    const response = await axios.get(url);
    
    if (response.data && response.data.output && response.data.output.abi) {
      return response.data.output.abi;
    }
    
    return null;
  } catch (error) {
    // Likely a 404, which means the contract is not in Sourcify
    return null;
  }
}

/**
 * Get ABI for a well-known contract (fallback)
 * @param {string} symbolOrName - Token symbol or contract name
 * @returns {Array|null} Hardcoded ABI or null
 */
function getWellKnownABI(symbolOrName) {
  // Common ABIs for well-known contracts
  const wellKnownABIs = {
    // ERC20 standard ABI
    'ERC20': [
      {
        "constant": true,
        "inputs": [],
        "name": "name",
        "outputs": [{"name": "", "type": "string"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [{"name": "_spender", "type": "address"}, {"name": "_value", "type": "uint256"}],
        "name": "approve",
        "outputs": [{"name": "", "type": "bool"}],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "totalSupply",
        "outputs": [{"name": "", "type": "uint256"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [{"name": "_from", "type": "address"}, {"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}],
        "name": "transferFrom",
        "outputs": [{"name": "", "type": "bool"}],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "decimals",
        "outputs": [{"name": "", "type": "uint8"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [{"name": "_owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "balance", "type": "uint256"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "symbol",
        "outputs": [{"name": "", "type": "string"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [{"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}],
        "name": "transfer",
        "outputs": [{"name": "", "type": "bool"}],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [{"name": "_owner", "type": "address"}, {"name": "_spender", "type": "address"}],
        "name": "allowance",
        "outputs": [{"name": "", "type": "uint256"}],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      }
    ]
  };
  
  return wellKnownABIs[symbolOrName] || null;
}

module.exports = {
  fetchContractABI,
}; 