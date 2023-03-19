// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract TokenBridge {
    address public bscToken;
    address public ethToken;
    uint256 public ethTotalSupply;
    uint256 public bscTotalSupply;

    event Bridge(address indexed from, address indexed to, uint256 amount);

    constructor(address _bscToken, address _ethToken) {
        bscToken = _bscToken;
        ethToken = _ethToken;

        // Set the initial total supply values for each chain
        ethTotalSupply = IERC20(_ethToken).totalSupply();
        bscTotalSupply = IERC20(_bscToken).totalSupply();
    }

    function bridgeToBsc(uint256 amount) external {
        require(IERC20(ethToken).balanceOf(msg.sender) >= amount, "Not enough tokens");
        require(IERC20(ethToken).approve(bscToken, amount), "Approval failed");

        // Calculate the conversion ratio based on the difference in total supply between chains
        uint256 conversionRatio = bscTotalSupply > ethTotalSupply ? bscTotalSupply / ethTotalSupply : ethTotalSupply / bscTotalSupply;

        // Adjust the amount to ensure the price remains the same on both chains
        uint256 adjustedAmount = amount / conversionRatio;

        require(IERC20(bscToken).transferFrom(msg.sender, address(this), adjustedAmount), "Transfer failed");

        // Update the total supply for the receiving chain
        bscTotalSupply += adjustedAmount;

        emit Bridge(msg.sender, bscToken, adjustedAmount);
    }

    function bridgeToEth(uint256 amount) external {
        require(IERC20(bscToken).balanceOf(msg.sender) >= amount, "Not enough tokens");
        require(IERC20(bscToken).approve(ethToken, amount), "Approval failed");

        // Calculate the conversion ratio based on the difference in total supply between chains
        uint256 conversionRatio = bscTotalSupply > ethTotalSupply ? bscTotalSupply / ethTotalSupply : ethTotalSupply / bscTotalSupply;

        // Adjust the amount to ensure the price remains the same on both chains
        uint256 adjustedAmount = amount / conversionRatio;

        require(IERC20(ethToken).transferFrom(msg.sender, address(this), adjustedAmount), "Transfer failed");

        // Update the total supply for the receiving chain
        ethTotalSupply += adjustedAmount;

        emit Bridge(msg.sender, ethToken, adjustedAmount);
    }

    function mint(uint256 amount) external {
        // Only the contract owner is allowed to mint tokens
        require(msg.sender == owner, "Only owner can mint tokens");

        // Mint tokens to the contract address
        require(IERC20(ethToken).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update the total supply for the Ethereum chain
        ethTotalSupply += amount;
    }

    function burn(uint256 amount) external {
        // Only the contract owner is allowed to burn tokens
        require(msg.sender == owner, "Only owner can burn tokens");

        // Burn tokens from the contract address
        require(IERC20(ethToken).transfer(msg.sender, amount), "Transfer failed");

        // Update the total supply for the Ethereum
    function bridgeToBsc(uint256 amount) external {
        require(IERC20(ethToken).balanceOf(msg.sender) >= amount, "Not enough tokens");

        // Calculate the equivalent amount of tokens on BSC chain
        uint256 equivalentAmount = amount.mul(conversionRatio);

        require(IERC20(ethToken).approve(bscToken, amount), "Approval failed");
        require(IERC20(bscToken).mint(address(this), equivalentAmount), "Minting failed");
        require(IERC20(bscToken).transfer(msg.sender, equivalentAmount), "Transfer failed");

        emit Bridge(msg.sender, bscToken, amount, equivalentAmount);
    }

    function bridgeToEth(uint256 amount) external {
        require(IERC20(bscToken).balanceOf(msg.sender) >= amount, "Not enough tokens");

        // Calculate the equivalent amount of tokens on Ethereum chain
        uint256 equivalentAmount = amount.div(conversionRatio);

        require(IERC20(bscToken).approve(ethToken, amount), "Approval failed");
        require(IERC20(ethToken).mint(address(this), equivalentAmount), "Minting failed");
        require(IERC20(ethToken).transfer(msg.sender, equivalentAmount), "Transfer failed");

        emit Bridge(msg.sender, ethToken, amount, equivalentAmount);
    }
}
