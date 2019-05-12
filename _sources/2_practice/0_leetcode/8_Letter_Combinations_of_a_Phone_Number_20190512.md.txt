# Letter Combinations of a Phone Number

문제 링크 :  [Link](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)

## 문제 목표
문제 링크 참조

## 문제 접근 방식
Backtracking 방식을 사용한다.  - 각 자리수에 대해 Recursive 방식으로 만들 수 있는 문자열을 나열하되, Recursion을 통해 나열된 문자열을 이어붙인다. 코드 참조

## Correct Code
```cpp
    vector<string> getCombinations(string digits){
        const char table[10][5] = {
           {NULL,NULL,NULL,NULL,NULL},    // 0
           {NULL,NULL,NULL,NULL,NULL},    // 1
           {'a','b','c',NULL,NULL},       // 2
           {'d','e','f',NULL,NULL},       // 3
           {'g','h','i',NULL,NULL},       // 4
           {'j','k','l',NULL,NULL},       // 5
           {'m','n','o',NULL,NULL},       // 6
           {'p','q','r','s',NULL},   // 7
           {'t','u','v',NULL,NULL},       // 8
           {'w','x','y','z',NULL},     // 9
        };
        vector<string> result;
        if(digits.length() == 0){
            return result;
        }
        if (digits.length() == 1){
            char digit = digits[0];
            int digitIndex = digit - '0';
            for(int i = 0 ; i < 5 ; i++){
                if(table[digitIndex][i] != NULL){          
                    string data = "";
                    data = data + table[digitIndex][i];
                    result.push_back(data);
                }
            }
            return result;
        }
        
        char digit = digits[0];
        int digitIndex = digit - '0';

        for(int j = 0 ; j < 5 ; j++){
            char letter = table[digitIndex][j];

            if(letter != NULL){
                string str = "";
                str = str + letter;
                vector<string> nextStr = getCombinations(digits.substr(1));
                for(vector<string>::iterator itor = nextStr.begin() ; itor != nextStr.end() ; ++itor){
                    result.push_back(str + *itor);
                }
            }
        }
    
        return result;        
    }
    vector<string> letterCombinations(string digits) {
        vector<string> result = getCombinations(digits);
        return result;
 
    }
```

## Time Complexity
각 자리수에 대해 가능한 모든 문자들을 나열하여야 하기 때문에
O(N^3 * M^4)의 Time Complexity를 가진다.(N : 3 가지 문자를 가지는 숫자의 개수, M : 4 가지 문자를 가지를 숫자의 개수)