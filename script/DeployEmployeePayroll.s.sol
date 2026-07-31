//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {EmployeePayroll} from "../src/EmployeePayroll.sol";

contract DeployEmployeePayroll is Script {
    EmployeePayroll employeePayroll;

    function run() public {
        vm.startBroadcast();
        employeePayroll = new EmployeePayroll();
        vm.stopBroadcast();
    }
}