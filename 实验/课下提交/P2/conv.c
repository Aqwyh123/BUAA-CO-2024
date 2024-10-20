#include <stdio.h>

int main()
{
    char space = ' ', newline = '\n';
    int matrix1[10][10], matrix2[10][10], result[10][10];
    int *x1 = &matrix1[0][0], *x2 = &matrix2[0][0], *r = &result[0][0];
    int m1, n1, m2, n2;
    scanf("%d %d %d %d", &m1, &n1, &m2, &n2);
    int num1 = m1 * n1, num2 = m2 * n2;
    for (int i = 0; i < num1; i++) {
        scanf("%d", x1++);
    }
    for (int i = 0; i < num2; i++) {
        scanf("%d", x2++);
    }
    int b1 = m1 - m2 + 1, b2 = n1 - n2 + 1;
    for (int i = 0; i < b1; i++) {
        for (int j = 0; j < b2; j++) {
            int sum = 0;
            for (int k = 0; k < m2; k++) {
                for (int l = 0; l < n2; l++) {
                    x1 = &matrix1[0][0], x2 = &matrix2[0][0];
                    int offset1 = i + k;
                    offset1 *= n1;
                    offset1 += j;
                    offset1 += l;
                    int offset2 = k * n2;
                    offset2 += l;
                    x1 += offset1;
                    x2 += offset2;
                    int v1 = *x1, v2 = *x2;
                    v1 *= v2;
                    sum += v1;
                }
            }
            r = &result[0][0];
            int offset = i * b2;
            offset += j;
            r += offset;
            *r = sum;
        }
    }
    for (int i = 0; i < b1; i++) {
        for (int j = 0; j < b2; j++) {
            r = &result[0][0];
            int offset = i * b2;
            offset += j;
            r += offset;
            printf("%d", *r);
            putchar(space);
        }
        putchar(newline);
    }
    return 0;
}