// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NormalStaking is ERC20, Ownable {
    using Address for address;
    using SafeERC20 for IERC20;
   
    IERC20 public acceptedToken;

    uint256 public flexibleBasisPoints;
    uint256 public oneMonthBasisPoints;
    uint256 public threeMonthsBasisPoints;
    uint256 public sixMonthsBasisPoints;
    uint256 public twelveMonthsBasisPoints;
 
    mapping(address => uint) public depositStart;
    mapping(address => uint) public TRVLBalanceOf;
    mapping(address => bool) public isDeposited;

    event DepositEvent(address indexed user, uint TRVLAmount, uint timeStart);
    event WithdrawEvent(address indexed user, uint TRVLAmount, uint interest);
    

    constructor (address _acceptedToken, uint256 _flexible, uint256 _30bps, uint256 _90bps, uint256 _180bps, uint256 _360bps) ERC20("tshares", "T-Shares") {
        acceptedToken = IERC20(_acceptedToken);
        flexibleBasisPoints = _flexible;
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
     }

    function deposit(uint _amount) payable public {
        require(_amount >=1e16, 'Error, deposit must be >= 0.01 TRVL');
        
        // If already have deposit, first withdrawInterests, and update balanceOf
        if(isDeposited[msg.sender]){
            withdrawInterests();
            TRVLBalanceOf[msg.sender] = TRVLBalanceOf[msg.sender] + _amount;
        }
        // If it doesn't have deposit, set the values
        else {
            TRVLBalanceOf[msg.sender] += _amount;
            depositStart[msg.sender] = block.timestamp;
            isDeposited[msg.sender] = true; //activate deposit status
        }
        
        acceptedToken.safeTransferFrom(
            msg.sender, 
            address(this),
            _amount
        );
        emit DepositEvent(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() public {
        require(isDeposited[msg.sender]==true, 'Error, no previous deposit');
        
        uint256 interest = calculateInterests(msg.sender);
        uint256 userBalance = TRVLBalanceOf[msg.sender];
        
        //reset depositer data
        TRVLBalanceOf[msg.sender] = 0;
        isDeposited[msg.sender] = false;

        
        //send funds to user
        
        _mint(msg.sender, interest);
        
        acceptedToken.safeTransfer(
            msg.sender,
            userBalance
        );
        

        emit WithdrawEvent(msg.sender, userBalance, interest);
    }
    
    function withdrawInterests () public {
        require(isDeposited[msg.sender]==true, 'Error, no previous deposit');
        
        uint256 interest = calculateInterests(msg.sender);
        
        // reset depositStart
        
        depositStart[msg.sender] = block.timestamp;
        
        // mint interests
        
        _mint(msg.sender, interest);
    }
    
    // calculates the interest for each second on timestamp
    
    function calculateInterests (address _user) public view returns (uint256 insterest) {
        // get balance and deposit time
        uint userBalance = TRVLBalanceOf[_user]; 
        uint depositTime = block.timestamp - depositStart[msg.sender];
        
        // calculate the insterest per year
        
        uint256 basisPoints = getBasisPoints(depositTime);
        uint256 interestPerYear = (userBalance * basisPoints) / (100000);
        
        // get the interest on depositTime
        
        uint256 interests = (interestPerYear / 365 days) * (depositTime);
        
        return interests;
    }
    
    function getBasisPoints (uint256 _depositTime) public view returns (uint256 basisPoints) {
        if(_depositTime < 30 days){
            return oneMonthBasisPoints;
        } else if (_depositTime < 90 days){
            return threeMonthsBasisPoints;
        } else if (_depositTime < 180 days){
            return sixMonthsBasisPoints;
        } else if (_depositTime < 360 days){
            return twelveMonthsBasisPoints;
        }
    }
    
    function changeInterestRate (uint256 _30bps, uint256 _90bps, uint256 _180bps, uint256 _360bps) public onlyOwner {
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
    }
    
    function mint (address _recipient, uint256 _amount) public onlyOwner{
        _mint(_recipient, _amount);
    }
}