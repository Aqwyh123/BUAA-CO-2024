#include <stdio.h>
int main()
{
    int matrix[1024];
    int n, m, t, index = 0;
    scanf("%d %d", &n, &m);
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            scanf("%d", &t);
            if (t != 0) {
                matrix[index++] = i;
                matrix[index++] = j;
                matrix[index++] = t;
            }
        }
    }
    for (int i = index - 3; i >= 0; i -= 2) {
        printf("%d %d %d\n", matrix[i], matrix[i + 1], matrix[i + 2]);
    }
    return 0;
}