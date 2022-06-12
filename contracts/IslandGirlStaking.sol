// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract IslandGirlStaking is ERC20, Ownable {
    using Address for address;
    using SafeERC20 for IERC20;
   
    IERC20 public acceptedToken;

    uint256 public flexibleBasisPoints;
    uint256 public oneMonthBasisPoints;
    uint256 public threeMonthsBasisPoints;
    uint256 public sixMonthsBasisPoints;
    uint256 public twelveMonthsBasisPoints;
 
    mapping(address => uint) public depositStart;
    mapping(address => uint) public IslandGirlBalanceOf;
    mapping(address => bool) public isDeposited;
    mapping(address => uint) public depositOption;

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

    function deposit(uint _amount, uint _option) payable public {
        require(_amount >=1e16, 'Error, deposit must be >= 0.01 TRVL');
        
        // If already have deposit, first withdrawInterests, and update balanceOf
        if(isDeposited[msg.sender]){
            withdrawInterests();
            IslandGirlBalanceOf[msg.sender] = IslandGirlBalanceOf[msg.sender] + _amount;
            depositStart[msg.sender] = block.timestamp;         
        }
        // If it doesn't have deposit, set the values
        else {
            IslandGirlBalanceOf[msg.sender] += _amount;
            depositStart[msg.sender] = block.timestamp;
            isDeposited[msg.sender] = true; //activate deposit status
            depositOption[msg.sender] = _option;
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
        uint256 userBalance = IslandGirlBalanceOf[msg.sender];
        
        //reset depositer data
        IslandGirlBalanceOf[msg.sender] = 0;
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
        uint userBalance = IslandGirlBalanceOf[_user]; 
        uint depositTime = block.timestamp - depositStart[msg.sender];
        uint option = depositOption[msg.sender];
        
        // calculate the insterest per year
        
        uint256 basisPoints = getBasisPoints(option);
        uint256 interestPerMili = (userBalance * basisPoints) / (100*30*24*3600*1000);
        
        // get the interest on depositTime
        
        uint256 interests =  interestPerMili * (depositTime);
        
        return interests;
    }
    
    function getBasisPoints (uint256 _option) public view returns (uint256 basisPoints) {
        if(_option == 0){
            return flexibleBasisPoints;
        } else if (_option == 1){
            return threeMonthsBasisPoints;
        } else if (_option == 2){
            return sixMonthsBasisPoints;
        } else if (_option == 3){
            return twelveMonthsBasisPoints;
        } else if (_option == 4){
            return twelveMonthsBasisPoints;
        }
    }
    
    function changeInterestRate (uint256 _flexible, uint256 _30bps, uint256 _90bps, uint256 _180bps, uint256 _360bps) public onlyOwner {
        flexibleBasisPoints = _flexible;
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
    }
    
    function mint (address _recipient, uint256 _amount) public onlyOwner{
        _mint(_recipient, _amount);
    }
}