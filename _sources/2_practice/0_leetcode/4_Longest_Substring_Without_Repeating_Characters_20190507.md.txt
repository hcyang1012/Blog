# Longest Substring Without Repeating Characters

문제 링크 :  [Link](https://leetcode.com/problems/longest-substring-without-repeating-characters/)

## 문제 목표
주어진 문자열 *s* 내에서 반복되는 글자 없는 가장 긴 substring을 찾아라.

## 접근 방식

반복되는 글자가 없으려면 Substring 내에 중복되는 글자가 없어야 한다.(애초에 중복되는 글자가 있으면 Substring이 성립하지 않는다.)

Sliding Sindow W[left,right] = s[left,right-1] 을 확장하거나 Forwarding 하면서 문자열을 찾는다.  확장하거나 Forward Shifting 하는 조건은 다음과 같다.

- 확장 : 확장하여도 W 내에 중복되는 글자가 없는 경우 (right++)
  - 확장을 하는 경우에는 left에서 시작하는 문자열이 더 길어질 수 있는지 확인하기 위해 right++을 통해 문자열을 확장하여야 한다.
- Forwarding: 확장하였을 때 중복되는 글자가 발생하는 경우 (left++)
  - Forwarding을 하는 경우에는 left로 시작하는 문자열은 더이상 확장이 불가능함을 의미하기 때문에 left를 Forwarding 하여 다음 문자로부터 확장이 가능한지 검사하여야 한다.

또한, 중복이 됨을 확인할 수 있어야 하기 때문에 Sliding Window W에 포함되어 있는 문자들에 대한 Set을 유지한다. 

- Set은 W의 확장이 이루어질 때 새 문자열이 추가된다.
- Set은 W의 Forwarding이 이루어질 때 left가 가리키던 문자열이 제거된다. 

## 예제

문장으로는 설명이 다소 복잡하기 때문에 그림으로 예제를 풀어보자.

![](https://docs.google.com/drawings/d/e/2PACX-1vQZ8mFdEk0pqTIdKne8WimFn5WbvXsTuKxIV5ZJWHdZMAIZwdLj1hIEVtk3vk6rEJuWkr3N5_zV5ghb/pub?w=1384&h=4333)

## Correct Code

```cpp
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        int left = 0, right = 0;
        set<char> charSet;
        int maxLength = 0;
        while(right <= s.length()){
            if(charSet.find(s[right]) == charSet.end()){
                charSet.insert(s[right]);
                maxLength = max(right - left,maxLength);
                right++;
            }else{
                charSet.erase(s[left]);
                maxLength = max(right - left,maxLength);            
                left++;
            }           
        }
        return maxLength;
    }
};
```

## Time Complexity

Sliding Window는 주어진 문자열의 길이까지만 확장되기 때문에 O(N) 의 Time Complexity를 가진다.