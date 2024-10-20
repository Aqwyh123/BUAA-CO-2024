#include<stdio.h>
#define LEN 1000
int main()
{
    int r[LEN] = { 1 };
    int n;
    scanf("%d", &n);
    int c = 1;
    for (int i = 1; i <= n; i++) {
        int up = 0;
        for (int j = 0; j < c; j++) {
            int *p = r;
            p += j;
            int s = *p;
            s *= i;
            s += up;
            *p = s % 10;
            up = s / 10;
        }
        while (up) {
            int *p = r;
            p += c;
            *p = up % 10;
            up /= 10;
            c++;
        }
    }
    for (int i = c - 1; i >= 0; i--) {
        int *p = r;
        p += i;
        printf("%d", *p);
    }
    putchar('\n');
    return 0;
}