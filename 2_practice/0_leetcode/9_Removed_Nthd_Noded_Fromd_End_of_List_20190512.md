# Remove Nth Node From End of List

문제 링크 :  [Link](https://leetcode.com/problems/remove-nth-node-from-end-of-list/)

## 문제 목표

주어진 Singly Linked List의 끝에서 N번째 Node를 제거한 결과를 찾아내라.

## 문제 접근 방식

List의 길이를 알아내야 하기 때문에 전체 List는 훑어야 한다.
다만, 끝에서 N번째 Node를 찾기 위해서는 다음과 같은 방식으로 가능하다.

1. Head 에서 N 번 만큼 List를 훑는다. (CurrentNode = CurrentNode->next)
2. N 번 훑은 후 Head를 TargetNode로 정한다. 
3. CurrentNode가 List의 끝에 도달할 때 까지 TargetNode와 CurrentNode를 전진시킨다.
4. CurrentNode가 Head에 도달하면 TargetNode가 제거 대상 Node이다.

## Correct Code
```cpp
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        int end = 0;
        
        ListNode *prevNode = NULL;
        ListNode *currentNode = head;
        ListNode *targetNode = NULL;
        
        while(end < n){
            currentNode = currentNode->next;
            end++;
        }
        targetNode = head;
        while(currentNode != NULL){
            prevNode = targetNode;
            currentNode = currentNode->next;
            targetNode = targetNode->next;            
        }
        if(head == targetNode){
            head = targetNode->next;
        }else{
            prevNode->next = targetNode->next;
        }
        
        return head;
    }
```

## Time Complexity
List를 한 번만 훑으면 되끼 때문에 O(N)의 Time Complexity를 가진다.