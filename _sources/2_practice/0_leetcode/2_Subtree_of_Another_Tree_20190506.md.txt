# Subtree of Another Tree

문제 링크 :  [Link](https://leetcode.com/problems/subtree-of-another-tree/)

## 문제 목표
한 Tree가 다른 하나의 Subtree인지를 밝혀라.

## 접근 방식

### Outer Loop
1. 주어진 S-Tree를 모두 Traverse한다.(Order는 상관 없음)
2. Tree Traverse 시 각 Node의 값이 T-Tree의 Root Node의 값과 일치하다면 Subtree Check
3. Subtree Check 결과가 True라면 True return, 그렇지 않으면 다음 Node Traverse
4. 모든 Node를 Traverse 하더라도 True가 나오지 않으면 False return

### Inner Loop (Subtree Check)
1. Root의 값이 다르면 False return
2. left,right에 대해 subtree check recursion
3. left,right 모두 결과가 True 이면 True return, 그렇지 않으면 False return


## Correct Code 
```cpp
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    bool _isSubtree(TreeNode *s, TreeNode *t,int parent = -1){
        TreeNode *sRoot = s;
        TreeNode *tRoot = t;
        if((sRoot == NULL) && (tRoot == NULL)){
            return true;
        }else{
            if(!((sRoot != NULL)  && (tRoot != NULL))){
                return false;
            }
        }
        if(s->val == t->val){
            return _isSubtree(sRoot->left,tRoot->left,s->val) && _isSubtree(sRoot->right,tRoot->right,s->val);
        }else{
            return false;
        }
    }
    bool traverse(TreeNode* s, TreeNode* t){
        if(s == NULL){
            //Do nothing
            return false;
        }
        if(s->val == t->val){
            bool result = _isSubtree(s,t);
            if(result == true){return true;}
        }
        bool result = false;
        result = traverse(s->left,t);
        if(result == true){return true;}
        result = traverse(s->right,t);
        if(result == true){return true;}
        
        return false;
    }
    bool isSubtree(TreeNode* s, TreeNode* t) {
        return traverse(s,t);
    }
};
```

## Time Complexity

S-Tree의 Node 의 개수를 N, T-Tree의 Node의 개수를 M이라고 했을 때, 
Subtree Check는 최대  M 개의 노드만큼 비교가 필요하고, 최대 N개의 Subtree Check를 수행해야 하기 때문에 **O(N*M)** 의 Time Complexity 발생