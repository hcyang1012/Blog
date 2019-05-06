# Minimum Absolute Difference in BST

문제 링크 :  [Link](https://leetcode.com/problems/minimum-absolute-difference-in-bst/)

## 문제 목표
BST에 있는 Node 둘 아무 두 Node를 선택하였을 때 그 차의 절대값(Absolute Difference)가 가장 작은 값을 찾아라.

## 접근 방식
1. BST 를 Sorted List 형태로 나열한다.
2. 나열된 List를 Traverse 하면서 인접한 두 값의 차를 구하였을 때 그 최소값이 정답.
3. **BST 의 In-order Traverse는 Sorted List를 나열하는 효과를 가진다.**

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
    int minDiff = INT_MAX;
    TreeNode *prev = NULL;
    void inorder(TreeNode* root){
        if(root == NULL){return;}
        inorder(root->left);
        if(prev != NULL){
            int a = prev->val;
            int b = root->val;
            int diff = 0;
            if(a > b){diff = a - b;}else{diff = b - a;}
            if(diff < minDiff){minDiff = diff;}
            
        }
        prev = root;
        inorder(root->right);
        
    }
    int getMinimumDifference(TreeNode* root) {
        inorder(root);
        return minDiff;
    }
};
```

