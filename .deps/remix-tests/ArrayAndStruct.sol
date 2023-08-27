// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ArrayTypes {

    // 固定長度 Array
    uint[8] array1;
    bytes1[5] array2;
    address[100] array3;

    // 可變長度 Array
    uint[] array4;
    bytes1[] array5;
    address[] array6;
    bytes array7;

    uint[] array8 = new uint[](5);
    bytes array9 = new bytes(9);

    function initArray() external pure returns(uint[] memory){
        uint[] memory x = new uint[](3);
        x[0] = 1;
        x[1] = 3;
        x[2] = 4;
        return(x);
    }  
    function arrayPush() public returns(uint[] memory){
        uint[2] memory a = [uint(1),2];
        array4 = a;
        array4.push(3);
        return array4;
    }
}

pragma solidity ^0.8.4;
contract StructTypes {

    struct Student{
        uint256 id;
        uint256 score; 
    }
    Student student; 

    // storage的struct
    function initStudent1() external{
        Student storage _student = student; // assign a copy of student
        _student.id = 11;
        _student.score = 100;
    }

    function initStudent2() external{
        student.id = 1;
        student.score = 80;
    }
    
    function initStudent3() external {
        student = Student(3, 90);
    }

    // key value
    function initStudent4() external {
        student = Student({id: 4, score: 60});
    }
}

pragma solidity ^0.8.4;
contract EnumTypes {

    enum ActionSet { Buy, Hold, Sell }

    ActionSet action = ActionSet.Buy;

    function enumToUint() external view returns(uint){
        return uint(action);
    }
}