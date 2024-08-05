# 2024
## 8月
### 8月5日
#### [600. 不含连续1的非负整数](https://leetcode.cn/problems/non-negative-integers-without-consecutive-ones/?envType=daily-question&envId=2024-08-05)
>给定一个正整数 n ，请你统计在 [0, n] 范围的非负整数中，有多少个整数的二进制表示中不存在 连续的 1 。  
> 示例 1:     
>输入: n = 5 输出: 5   
解释:
下面列出范围在 [0, 5] 的非负整数与其对应的二进制表示：     
0 : 0       
1 : 1       
2 : 10      
3 : 11      
4 : 100     
5 : 101     
其中，只有整数 3 违反规则（有两个连续的 1 ），其他 5 个满足规则。       
> 示例 2:     
输入: n = 1
输出: 2       
> 示例 3:     
输入: n = 2
输出: 3

这个问题可以使用动态规划来解决。    
##### 具体步骤：
1. 理解问题：我们要找到在 [0, n] 范围内的所有非负整数中，其二进制表示中没有连续的 1 的整数数量。例如，数字 5 的二进制表示为 101，不包含连续的 1，所以它是符合条件的。而数字 3 的二进制表示为 11，包含连续的 1，所以它不符合条件。
2. Fibonacci 数列的联系：我们可以发现一个规律，如果一个整数的二进制表示中没有连续的 1，那么它可以由前一个或前两个较小的整数构成。这有点像 Fibonacci 数列的构建方式。具体来说：
    - 长度为 1 的二进制字符串中没有连续 1 的有 2 个：0 和 1。
    - 长度为 2 的二进制字符串中没有连续 1 的有 3 个：00、01 和 10。
    - 长度为 3 的二进制字符串中没有连续 1 的有 5 个：000、001、010、100 和 101。
3. 动态规划状态转移：我们使用两个数组 dp0 和 dp1 分别表示以 0 和 1 结尾的、长度为 i 的二进制字符串中没有连续 1 的个数。
    - dp0[i] 表示长度为 i，以 0 结尾的二进制字符串个数。
    - dp1[i] 表示长度为 i，以 1 结尾的二进制字符串个数。
4. 状态转移方程：
    - dp0[i] = dp0[i-1] + dp1[i-1]，因为可以在长度为 i-1 的所有字符串后面加一个 0。
    - dp1[i] = dp0[i-1]，因为可以在长度为 i-1 的、以 0 结尾的所有字符串后面加一个 1，但不能在以 1 结尾的字符串后面再加一个 1。
5. 结果：我们需要将上述状态转移方程计算到 n，然后将所有结果累加。

    
    class Solution {
        public int findIntegers(int n) {
            // Convert n to binary and get the length
            String binary = Integer.toBinaryString(n);
            int len = binary.length();
    
            // Arrays to store the counts
            int[] dp0 = new int[len + 1];
            int[] dp1 = new int[len + 1];
    
            // Initialize base cases
            dp0[1] = 1; // 0
            dp1[1] = 1; // 1
    
            // Fill the dp arrays
            for (int i = 2; i <= len; i++) {
                dp0[i] = dp0[i - 1] + dp1[i - 1];
                dp1[i] = dp0[i - 1];
            }
    
            // Result to store the count of valid numbers
            int result = 0;
    
            // Variable to store previous digit
            int prevBit = 0;
    
            // Traverse the binary representation of n
            for (int i = 0; i < len; i++) {
                if (binary.charAt(i) == '1') {
                    // Add the count of valid numbers of length (len - i - 1)
                    result += dp0[len - i];
                    if (prevBit == 1) {
                        // If there are consecutive ones, break
                        break;
                    }
                    prevBit = 1;
                } else {
                    prevBit = 0;
                }
    
                // If we are at the last bit
                if (i == len - 1) {
                    result += 1;
                }
            }
    
            return result;
        }
    }
##### 解释:
- 转换与长度计算：将 n 转换为二进制字符串，并计算其长度 len。
- 初始化：初始化两个数组 dp0 和 dp1。
- 填充数组：使用状态转移方程填充数组。
- 结果计算：遍历二进制字符串的每一位，如果遇到 1，则累加有效数字的数量，并且根据前一位判断是否有连续的 1。

这个方法的时间复杂度是 O(log(n))，因为处理的最大位数是二进制表示的位数，空间复杂度也是 O(log(n))。这样就能有效地统计范围内符合条件的整数数量。
    

### 8月4日
#### [572. 另一棵树的子树](https://leetcode.cn/problems/subtree-of-another-tree/description/?envType=daily-question&envId=2024-08-04)
>给你两棵二叉树 root 和 subRoot 。检验 root 中是否包含和 subRoot 具有相同结构和节点值的子树。如果存在，返回 true ；否则，返回 false 。
>二叉树 tree 的一棵子树包括 tree 的某个节点和这个节点的所有后代节点。tree 也可以看做它自身的一棵子树。        
> 示例 1：     
> 输入：root = [3,4,5,1,2], subRoot = [4,1,2]      
> 输出：true       
> 示例 2：     
> 输入：root = [3,4,5,1,2,null,null,null,null,0], subRoot = [4,1,2]        
> 输出：false

关于二叉树，我自然首先想到递归，思路就是暴力遍历 root 上每个子树与 subRoot 比较是否相等，遍历子树需要一次 dfs ，判断是否相等也通过 dfs 来判断两个树上每个节点值
是否相等。

    class Solution {
        public boolean isSubtree(TreeNode root, TreeNode subRoot) {
            return dfs(root,subRoot);
        }
    
        boolean dfs(TreeNode r,TreeNode s){
            if(r == null){
                return false;
            }
    
            return check(r,s) || dfs(r.left,s) || dfs(r.right,s);
        }
    
        boolean check(TreeNode r,TreeNode s){
            if(r == null && s == null){
                return true;
            }
            if(r == null || s == null || r.val != s.val){
                return false;
            }
    
            return check(r.left,s.left) && check(r.right,s.right);
        }
    }
复杂度分析：
- 时间复杂度：对于每一个 s 上的点，都需要做一次深度优先搜索来和 t 匹配，匹配一次的时间代价是 O(∣t∣)，那么总的时间代价就是 O(∣s∣×∣t∣)。故渐进时间复杂度为 O(∣s∣×∣t∣)。
- 空间复杂度：假设 s 深度为 ds ，t 的深度为 dt，任意时刻栈空间的最大使用代价是O(max{ds ,dt})。故渐进空间复杂度为 O(max{ds,dt})。

### 8月3日
#### [3143. 正方形中的最多点数](https://leetcode.cn/problems/maximum-points-inside-the-square/?envType=daily-question&envId=2024-08-03)
>给你一个二维数组 points 和一个字符串 s ，其中 points[i] 表示第 i 个点的坐标，s[i] 表示第 i 个点的 标签 。如果一个正方形的中心在 (0, 0) ，所有边都平行于坐标轴，且正方形内 不 存在标签相同的两个点，那么我们称这个正方形是 合法 的。请你返回 合法 正方形中可以包含的 最多 点数。  
>注意：    
>如果一个点位于正方形的边上或者在边以内，则认为该点位于正方形内。正方形的边长可以为零。
>
>输入：points = [[2,2],[-1,-2],[-4,4],[-3,1],[3,-3]], s = "abdca"  输出：2    
> 解释：边长为 4 的正方形包含两个点 points[0] 和 points[1] 。
>
> 输入：points = [[1,1],[-2,-2],[-2,2]], s = "abb"     
> 输出：1  
> 解释： 边长为 2 的正方形包含 1 个点 points[0] 。

这道题没有思路，看题解的时候对于合法正方形半径必须都小于每个字符的次小半径很难理解，通过后 charGPT 理解了，贴一下
![1](_media/img.jpg)
![2](_media/img_1.jpg)

复杂度分析：   
时间复杂度：O(n)，其中 n 是数组的长度。     
空间复杂度：O(∣Σ∣)，其中 Σ 是小写字符集的大小， Σ=26。

    class Solution {
        public int maxPointsInsideSquare(int[][] points, String s) {
            int[] min1 = new int[26];
            int n = s.length();
            int min2 = 1000000001;
            Arrays.fill(min1,1000000001);
            for(int i = 0; i < n; i++){
                int[] point = points[i];
                int j = s.charAt(i) - 'a';
                int d = Math.max(Math.abs(point[0]),Math.abs(point[1]));
                if(d < min1[j]){
                    min2 = Math.min(min2,min1[j]);
                    min1[j] = d;
                }else if(d < min2){
                    min2 = d;
                }
            }
    
            int res = 0;
            for(int i : min1){
                if(i < min2){
                    res++;
                }
            }
    
            return res;
        }
    }

### 8月2日
#### [LCP 40. 心算挑战](https://leetcode.cn/problems/uOAnQW/?envType=daily-question&envId=2024-08-01)
>「力扣挑战赛」心算项目的挑战比赛中，要求选手从 N 张卡牌中选出 cnt 张卡牌，若这 cnt 张卡牌数字总和为偶数，则选手成绩「有效」且得分为 cnt 张卡牌数字总和。 给定数组 cards 和 cnt，其中 cards[i] 表示第 i 张卡牌上的数字。 请帮参赛选手计算最大的有效得分。若不存在获取有效得分的卡牌方案，则返回 0。
> 
>示例 1：
>输入：cards = [1,2,8,9], cnt = 3 
>输出：18  
>解释：选择数字为 1、8、9 的这三张卡牌，此时可获得最大的有效得分 1+8+9=18。
>
>示例 2：
>输入：cards = [3,3,1], cnt = 1
>输出：0   
>解释：不存在获取有效得分的卡牌方案。     
> 
>提示：    
>1 <= cnt <= cards.length <= 10^5   
>1 <= cards[i] <= 1000

首先第一个想到的是肯定需要从大到小进行排序，然后取出前 cnt 张卡牌，如果和为偶，直接返回，如果为奇，则有两种选择：

- 在剩下中找到最大的奇数替换已选中最小的偶数；
- 在剩下中找到最大的偶数替换已选中最小的奇数；

在这两种方案中选择和最大的即可

    class Solution {
        public int maxmiumScore(int[] cards, int cnt) {
            Arrays.sort(cards);
            int res = 0;
            int tmp = 0;
            int odd = -1;
            int even = -1;
            for(int i = cards.length -1; i >= cards.length-cnt; i--){
                tmp += cards[i];
                if((cards[i] & 1) == 0){
                    even = cards[i];
                }else{
                    odd = cards[i];
                }
            }
    
            if((tmp & 1 )== 0){
                return tmp;
            }
    
            for(int i = cards.length - cnt - 1; i >= 0; i--){
                if((cards[i] & 1) != 0){
                    if(even != -1){
                        res = Math.max(res,tmp + cards[i] - even);
                        break;
                    }
                }
            }
    
            for(int i = cards.length - cnt - 1; i >= 0; i--){
                if((cards[i] & 1 )== 0){
                    if(odd != -1){
                        res = Math.max(res,tmp + cards[i] - odd);
                        break;
                    }
                }
            }
    
            return res;
        }
    }

由于是升序排列，逆序遍历，所以取出最后一张卡牌时，odd 和 even 是所选卡牌中最小的奇数和偶数。     
提醒一下，num & 1 可以快速判断奇偶，num & 1 == 0 为偶，否则为奇