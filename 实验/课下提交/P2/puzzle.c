#include <stdio.h>

int matrix[8][8];
int n, m;
int start_i, start_j, end_i, end_j;

int puzzle(int i, int j);
int main()
{
    scanf("%d %d", &n, &m);

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int *p = &matrix[0][0];
            int offset = i << 3;
            offset += j;
            offset <<= 2;
            p = (int *)((char *)p + offset);
            scanf("%d", p);
        }
    }

    scanf("%d %d %d %d", &start_i, &start_j, &end_i, &end_j);
    start_i--; start_j--; end_i--; end_j--;

    int result = puzzle(start_i, start_j);
    printf("%d\n", result);
}

int puzzle(int i, int j)
{
    if (i == end_i && j == end_j) {
        return 1;
    }

    if (i < 0 || i >= n || j < 0 || j >= m) {
        return 0;
    }

    int *p = &matrix[0][0];
    int offset = i << 3;
    offset += j;
    offset <<= 2;
    p = (int *)((char *)p + offset);
    int tp = *p;
    if (tp == 1) {
        return 0;
    }
    *p = 1;

    int result = 0;
    int tm = puzzle(i - 1, j);
    result += tm;
    tm = puzzle(i + 1, j);
    result += tm;
    tm = puzzle(i, j - 1);
    result += tm;
    tm = puzzle(i, j + 1);
    result += tm;

    *p = 0;
    return result;
}