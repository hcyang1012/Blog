# Add Two Numbers

문제 링크 :  [Link](https://leetcode.com/problems/add-two-numbers/)

## 문제 목표
List 형태로 표현된 두 수의 합을 구하여라.

## 접근 방식
1. 두 List를 한 자리씩 더한다.
- (여기서 계산되는 합) = (두 List의 값의 합) + Carry 이 된다.
2. 계산된 값을 담기 위해 새 List Node를 만든다.
- (새로 만들어진 List Node 의 값) = (합 % 10) 이다. 
- (합 / 10) 값은 Carry가 된다.
3. 모든 자리수를 더할 때 까지 List를 계속 탐색하되, 어느 한 쪽이 먼저 자리수가 끝난다면 자리수가 끝난 쪽은 항상 0을 더하게 한다.
4. 모든 List Node에 대해 덧셈을 수행한 후 Carry가 남아 있다면 새 List를 만든 후 Carry를 더한다. 

## Correct Code 
```cpp
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode *newList = new ListNode(0);
        ListNode *result = newList;
        ListNode *currentL1 = l1;
        ListNode *currentL2 = l2;
        
        int carry = 0;
        while((currentL1 != NULL) || (currentL2 != NULL)){
            int a = 0, b = 0;
            if(currentL1 != NULL){
                a = currentL1->val;
            }
            if(currentL2 != NULL){
                b = currentL2->val;
            }
            
            int sum = a + b + carry;
            carry = sum / 10;
            sum = sum % 10;
            
            newList->next = new ListNode(0);
            newList->next->val = sum;
            newList = newList->next;
            
                      
            if(currentL1 != NULL){
                currentL1 = currentL1->next;
            }
            if(currentL2 != NULL){
                currentL2 = currentL2->next;
            }
        }
        if(carry > 0){
            newList->next = new ListNode(0);
            newList->next->val = carry;
        }
        return result->next;
    }
};
```
## Trick
위 코드에서는 코드 단순함을 위해 result의 첫 Node는 Dummy로 사용될뿐 결과적으로는 사용하지 않는다. 즉 마지막 return 시 result->next를 리턴함으로써 메모리가 약간 낭비되는 대신 코드의 간결함을 취하였다. 

## Time Complexity
두 List 의 길이를 각각 M,N이라고 할 때 O(MAX(M,N))이 된다.