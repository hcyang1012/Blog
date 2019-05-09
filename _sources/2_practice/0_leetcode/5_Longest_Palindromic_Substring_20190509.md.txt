# Longest Palindromic Substring

문제 링크 :  [Link](https://leetcode.com/problems/longest-palindromic-substring/)

## 문제 목표
### Palindrom String
좌->우, 우->좌 어느 방향으로 읽어도 같은 문자열
- 예) aabaa

주어진 문자열 *s* 내에 가장 긴 Palindrom substring을 찾아라.

## 접근 방식
### Expand
문자열 *s* 내 어느 한 문자를 중심으로 좌우 글자가 달라 질 때 까지 문자열을 좌우로 확장시킨다.

- 예) cabac, b에서 expand 한다고 할 때,
  - b
  - aba
  - cabac

Palindrom String의 길이는 짝수, 홀수 모두 가능하기 때문에 Expand는 두 경우 모두를 고려해서 수행해야 한다.

### 알고리즘

 1. *s*의 길이가 2 미만이면 *s*를 리턴한다. (문자열 *s* 자체가 Palindrom)
 2. 각 *i*에 대해 다음을 수행한다. (*i* 는 *[0,len(s)-1]* 범위의 정수)
  - Expand(s,i,i) //홀수 길이의 Palndrom 계산
  - Expand(s,i,i+1) //홀수 길이의 Palndrom 계산
  - 각 Expand 수행 시 마다 가장 긴 길이의 Palindrom 을 찾아 기억한다.

## Correct Code
```cpp
class Solution {
public:
    int maxLen = 0;
    int strStart = 0;
    void expand(const string &s, const int leftStart, const int rightStart){
        int left = leftStart;
        int right = rightStart;
        while(left >= 0 && right < s.length() && s.at(left) == s.at(right)){
            left--;
            right++;
        }
        int len = right - left - 1;
        if(maxLen <= len){
            maxLen = len;
            strStart = left+1;
        }
    }
    string longestPalindrome(string s) {
        if(s.length() < 2){
            return s;
        }
        for(int i = 0 ; i < s.length()-1 ; i++){
            expand(s,i,i);
            expand(s,i,i+1);
        }
        return s.substr(strStart,maxLen);
    }
};
```

## Time Complexity
Expand의 가 O(N)의 Time Complexity를 가지고, 문자열 길이만큼 Expand함수가 수행되므로 O(N^2) 의 Time Complexity를 가진다.