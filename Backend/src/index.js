require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { processUserIntent } = require('./services/intentProcessor');
const { fetchContractABI } = require('./services/abiService');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Process user intent and return transaction package
app.post('/api/process-intent', async (req, res) => {
  try {
    const { message, walletAddress } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }
    
    if (!walletAddress) {
      return res.status(400).json({ error: 'Wallet address is required' });
    }
    
    const transactionPackage = await processUserIntent(message, walletAddress);
    res.status(200).json(transactionPackage);
  } catch (error) {
    console.error('Error processing intent:', error);
    res.status(500).json({ 
      error: 'Failed to process your request',
      details: error.message
    });
  }
});

// Get ABI for a contract
app.get('/api/abi/:contractAddress', async (req, res) => {
  try {
    const { contractAddress } = req.params;
    const abi = await fetchContractABI(contractAddress);
    
    if (!abi) {
      return res.status(404).json({ error: 'ABI not found for the given contract' });
    }
    
    res.status(200).json({ abi });
  } catch (error) {
    console.error('Error fetching ABI:', error);
    res.status(500).json({ 
      error: 'Failed to fetch ABI',
      details: error.message
    });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
}); 