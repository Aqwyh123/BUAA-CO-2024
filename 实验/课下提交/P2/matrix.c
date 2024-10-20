#include <stdio.h>

int main()
{
    char next = '\n', space = ' ';
    int matrix_1[8 * 8], matrix_2[8 * 8], matrix_3[8 * 8];
    int *m1 = matrix_1, *m2 = matrix_2, *m3 = matrix_3;
    int n = 0;
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            int offset = i * n;
            offset += j;
            int *m = m1 + offset;
            scanf("%d", m);
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            int offset = i * n;
            offset += j;
            int *m = m2 + offset;
            scanf("%d", m);
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            int temp = 0;
            for (int k = 0; k < n; k++) {
                int offset_1 = i * n;
                offset_1 += k;
                int offset_2 = k * n;
                offset_2 += j;
                int *m1 = matrix_1 + offset_1;
                int *m2 = matrix_2 + offset_2;
                int mult = *m1 * *m2;
                temp += mult;
            }
            int offset = i * n;
            offset += j;
            int *m = matrix_3 + offset;
            *m = temp;
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            int offset = i * n;
            offset += j;
            int *m = matrix_3 + offset;
            printf("%d", *m);
            int bound = n - 1;
            if (j < bound) {
                putchar(space);
            }
        }
        putchar(next);
    }
    return 0;
}