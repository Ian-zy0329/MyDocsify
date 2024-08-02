# 2024
## 7月
## 8月
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

#### [3128. 直角三角形](https://leetcode.cn/problems/right-triangles/?envType=daily-question&envId=2024-08-02)
>给你一个二维 boolean 矩阵 grid 。请你返回使用 grid 中的 3 个元素可以构建的 直角三角形 数目，且满足 3 个元素值 都 为 1 。注意：如果 grid 中 3 个元素满足：一个元素与另一个元素在 同一行，同时与第三个元素在 同一列 ，那么这 3 个元素称为一个 直角三角形 。这 3 个元素互相之间不需要相邻。        
> 
> 示例 1：
> 输入：grid = [[0,1,0],[0,1,1],[0,1,0]]   
> 输出：2   
> 解释：有 2 个直角三角形。    
> 示例 2：
> 输入：grid = [[1,0,0,0],[0,1,0,1],[1,0,0,0]]     
> 输出：0      
> 解释：没有直角三角形。

