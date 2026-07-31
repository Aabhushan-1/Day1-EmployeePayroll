//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {EmployeePayroll} from "../src/EmployeePayroll.sol";

contract EmployeePayrollTest is Test {
    EmployeePayroll employeePayroll;

    address abu = makeAddr("abu");
    uint256 salary = 100 ether;

    uint256 initialFund = 1000 ether;

    event EmployeeAdded(address employeeWalletAddress, uint256 employeeSalary);
    event EmployeeRemoved(address employeeWalletAddress);
    event EmployeePaid(address employeeWalletAddress, uint256 amountPaid);

    function setUp() public {
        employeePayroll = new EmployeePayroll();
        employeePayroll.fund{value: initialFund}();
    }

    function addEmp() private {
        employeePayroll.addEmployee(abu, salary);
    }

    function test_ContractHasFunds() public view {
        assertEq(address(employeePayroll).balance, initialFund);
    }

    function test_isEmployee_Returns_True_For_Existing_Employee() public {
        addEmp();
        assertEq(employeePayroll.isEmployee(abu), true);
    }

    function test_isEmployee_Returns_False_For_NonExisting_Employee() public view {
        assertEq(employeePayroll.isEmployee(abu), false);
    }

    function test_addEmployee_Reverts_For_Zero_Address() public {
        vm.expectRevert("Address is Zero.");
        employeePayroll.addEmployee(address(0), salary);
    }

    function test_addEmployee_Reverts_If_Employee_Already_Exists() public {
        addEmp();
        vm.expectRevert("Employee already exists.");
        employeePayroll.addEmployee(abu, salary);
    }

    function test_addEmployee_Emits_For_Successfully_Adding_New_Employee() public {
        vm.expectEmit();
        emit EmployeeAdded(abu, salary);
        addEmp();
    }

    function test_addEmployee_Updates_Employee_Array() public {
        uint256 initialEmployeesLength = employeePayroll.getEmployees().length;
        addEmp();
        uint256 finalEmployeesLength = employeePayroll.getEmployees().length;

        assertEq(finalEmployeesLength, initialEmployeesLength + 1);
    }

    function test_addEmployee_Updates_Salary_Mapping() public {
        addEmp();

        assertEq(employeePayroll.getSalaryOfThisAddress(abu), salary);
    }

    function test_addEmployee_Updates_Index_Mapping() public {
        addEmp();

        assertEq(employeePayroll.getIndexOfThisAddress(abu), 0);
    }

    function test_removeEmployee_Reverts_For_Zero_Address() public {
        vm.expectRevert("Address is Zero.");
        employeePayroll.removeEmployee(address(0));
    }

    function test_removeEmployee_Reverts_If_Employee_Doest_Exists() public {
        vm.expectRevert("Employee doesn't exists.");
        employeePayroll.removeEmployee(abu);
    }

    function test_removeEmployee_Emits_For_Successfully_Removing_Employee() public {
        addEmp();

        vm.expectEmit();
        emit EmployeeRemoved(abu);
        employeePayroll.removeEmployee(abu);
    }

    function test_removeEmployee_Updates_Employees() public {
        addEmp();
        uint256 indexOfAbu = employeePayroll.getIndexOfThisAddress(abu);
        employeePayroll.removeEmployee(abu);
        address[] memory _employees = employeePayroll.getEmployees();

        assertEq(_employees[indexOfAbu], address(0));
    }

    function test_runPayroll_Reverts_If_Not_Enough_ETH() public {
        employeePayroll.addEmployee(abu, initialFund + 1);

        vm.expectRevert("Not Enough ETH for payroll");
        employeePayroll.runPayroll();
    }

    function test_runPayroll_Successfully_Pays() public {
        uint256 initialBalanceOfContract = address(employeePayroll).balance;
        uint256 initialBalanceOfAbu = abu.balance;

        addEmp();

        employeePayroll.runPayroll();

        uint256 finalBalanceOfContract = address(employeePayroll).balance;
        uint256 finalBalanceOfAbu = abu.balance;

        assertEq(finalBalanceOfContract, initialBalanceOfContract - salary);
        assertEq(finalBalanceOfAbu, initialBalanceOfAbu + salary);
    }

    function test_runPayroll_Emits_For_Successful_Payments() public {
        addEmp();

        vm.expectEmit();
        emit EmployeePaid(abu, salary);
        employeePayroll.runPayroll();
    }

    function test_runPayroll_Doesnt_Revert_For_Zero_Address() public {
        address user = makeAddr("user");
        employeePayroll.addEmployee(user, salary);
        addEmp();
        employeePayroll.removeEmployee(abu);

        vm.expectEmit();
        emit EmployeePaid(user, salary);
        employeePayroll.runPayroll();
    }

    function test_getSalaryOfThisAddress() public {
        addEmp();

        assertEq(employeePayroll.getSalaryOfThisAddress(abu), salary);
    }

    function test_getEmployees() public {
        address[] memory _initialEmployees = employeePayroll.getEmployees();

        addEmp();

        address[] memory _finalEmployees = employeePayroll.getEmployees();

        assertEq(employeePayroll.getEmployees(), _finalEmployees);
        assertNotEq(employeePayroll.getEmployees(), _initialEmployees);
    }

    function test_getIndexOfThisAddress() public {
        addEmp();

        assertEq(employeePayroll.getIndexOfThisAddress(abu), 0);
    }
}
