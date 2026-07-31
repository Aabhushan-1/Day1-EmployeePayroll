// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract EmployeePayroll {
    address private immutable i_owner;
    address[] private employees;
    mapping(address => uint256) private salaryOfThisAddress;
    mapping(address => uint256) private indexOf;

    event EmployeeAdded(address employeeWalletAddress, uint256 employeeSalary);
    event EmployeeRemoved(address employeeWalletAddress);
    event EmployeePaid(address employeeWalletAddress, uint256 amountPaid);

    constructor() {
        i_owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == i_owner, "Not Owner");
        _;
    }

    function isAddressZero(address employeeWalletAddress) private pure {
        if (employeeWalletAddress == address(0)) {
            revert("Address is Zero.");
        }
    }

    function isEmployee(address employeeWalletAddress) public view returns (bool) {
        address[] memory _employees = employees;

        for (uint256 i = 0; i < _employees.length; i++) {
            if (employeeWalletAddress == _employees[i]) return true;
        }

        return false;
    }

    function addEmployee(address employeeWalletAddress, uint256 employeeSalary) public isOwner {
        isAddressZero(employeeWalletAddress);

        if (isEmployee(employeeWalletAddress)) {
            revert("Employee already exists.");
        }

        employees.push(employeeWalletAddress);
        salaryOfThisAddress[employeeWalletAddress] = employeeSalary;
        indexOf[employeeWalletAddress] = employees.length - 1;

        emit EmployeeAdded(employeeWalletAddress, employeeSalary);
    }

    function removeEmployee(address employeeWalletAddress) public isOwner {
        isAddressZero(employeeWalletAddress);

        if (!isEmployee(employeeWalletAddress)) {
            revert("Employee doesn't exists.");
        }

        delete salaryOfThisAddress[employeeWalletAddress];
        delete employees[indexOf[employeeWalletAddress]];
        delete indexOf[employeeWalletAddress];

        emit EmployeeRemoved(employeeWalletAddress);
    }

    function runPayroll() public isOwner {
        address[] memory _employees = employees;
        uint256 lengthOfArray = _employees.length;

        uint256 totalAmountToPay;

        for (uint256 i = 0; i < lengthOfArray; i++) {
            address employeeWalletAddress = _employees[i];

            if (employeeWalletAddress == address(0)) continue;

            uint256 salaryOfThisEmployee = salaryOfThisAddress[employeeWalletAddress];

            totalAmountToPay += salaryOfThisEmployee;
        }

        if (totalAmountToPay > address(this).balance) {
            revert("Not Enough ETH for payroll");
        }

        for (uint256 i = 0; i < lengthOfArray; i++) {
            address employeeWalletAddress = employees[i];

            if (employeeWalletAddress == address(0)) continue;

            uint256 salaryOfThisEmployee = salaryOfThisAddress[employeeWalletAddress];

            (bool success,) = address(employeeWalletAddress).call{value: salaryOfThisEmployee}("");
            require(success, "Payroll Failed!!!");

            emit EmployeePaid(employeeWalletAddress, salaryOfThisEmployee);
        }
    }

    function fund() public payable {
        require(msg.value > 0, "Send More ETH");
    }

    function getEmployees() public view returns (address[] memory) {
        return employees;
    }

    function getSalaryOfThisAddress(address employeeWalletAddress) public view returns (uint256) {
        return salaryOfThisAddress[employeeWalletAddress];
    }

    function getIndexOfThisAddress(address employeeWalletAddress) public view returns (uint256) {
        return indexOf[employeeWalletAddress];
    }
}
