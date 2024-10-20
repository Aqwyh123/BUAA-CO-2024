#include <stdio.h>
int G[8][8];    // 采用邻接矩阵存储图中的边 s0
int book[8];    // 用于记录每个点是否已经走过 s1
int m, n, ans; // s2, s3, s4

void dfs(int x) // a0
{
    int *graph, *record; // t0, t1
    int offset; // t2
    int flag, i; // t3, t4
    int temp1, temp2; // t5, t6

    record = book + x;
    *record = 1;

    // 判断是否经过了所有的点
    flag = 1;
    i = 0;
    while (i < n) {
        record = book + i;
        temp1 = *record;
        flag &= temp1;
        i++;
    }
    // 判断是否形成一条哈密顿回路
    graph = G;
    offset = x * 8;
    graph += offset;
    temp1 = *graph;
    if (flag && temp1) {
        ans = 1;
        return;
    }
    // 搜索与之相邻且未经过的边
    i = 0;
    while (i < n) {
        record = book + i;
        temp1 = *record;
        graph = G;
        offset = x * 8;
        offset += i;
        graph += offset;
        temp2 = *graph;
        if (!temp1 && temp2) {
            dfs(i);
        }
        i++;
    }
    record = book + x;
    *record = 0;
}

int main()
{
    scanf("%d%d", &n, &m); // s2, s3
    int i = 0; // t0
    while (i < m) {
        int x, y; // t1, t2
        int *graph; // t3
        int offset; // t4
        scanf("%d%d", &x, &y);
        x -= 1;
        y -= 1;
        graph = G;
        offset = x * 8;
        offset += y;
        graph += offset;
        *graph = 1;
        graph = G;
        offset = y * 8;
        offset += x;
        graph += offset;
        *graph = 1;
        i++;
    }
    // 从第0个点（编号为1）开始深搜
    dfs(0);
    printf("%d", ans);
    return 0;
}