# Container With Most Water

문제 링크 :  [Link](https://leetcode.com/problems/container-with-most-water/)

## 문제 목표

수평선에 여러 개의 막대를 세운 후 그 중 두개의 막대를 선택하여 만든 컨테이너들 중 가장 크기가 큰 컨테이너의 크기를 구해라.

## 접근 방식

### Brute Force
간단하니 아래 코드 참조 : O(N^2)의 Time Complexity를 가진다.
```cpp
class Solution {
public:
    int maxArea(vector<int>& height) {
        int maxWater = 0;
        for(int i = 0 ; i < height.size() ; i++){
            for(int j = i+1 ; j < height.size() ; j++){
                int w = j - i;
                int h = min(height.at(i),height.at(j));
                int water = w * h;
                if(maxWater <= water){
                    maxWater = water;
                }
            }
        }
        return maxWater;
    }
};
```

### Greedy Approach

1. 제일 바깥의 두 막대를 선택한다. (left,right)
2. 두 막대 중 왼쪽 막대의 길이가 짧거나 같은 경우 left++
3. 두 막대 중 오른쪽 막대의 길이가 길면 right--
4. left 와 right가 만날때까지 1~3을 반복한다.
5. 1~3을 반복하면서 매 번 컨테이너의 크기를 게산하되, 그 중 가잔 큰 컨테이너의 크기를 리턴한다.

## Code
```cpp

class Solution {
public:
    int maxArea(vector<int>& height) {
        int maxWater = 0;
        int left = 0, right = height.size() - 1;
        while(left < right){
            int w = right - left;
            int h = min(height.at(left),height.at(right));
            int water = w * h;
            if(water >= maxWater){
                maxWater = water;
            }
            if(height.at(right) < height.at(left)){
                right--;
            }else{
                left++;
            }
        }
        return maxWater;
    }
};

```
