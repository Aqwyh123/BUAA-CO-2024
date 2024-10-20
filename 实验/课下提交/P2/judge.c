#include <stdio.h>

int main()
{
    char str[25];
    char *s = str;
    int n = 0;
    scanf("%d", &n);
    getchar();
    for (int i = 0; i < n; i++) {
        *s++ = getchar();
    }
    char *t = str;
    s--;
    int flag = 1;
    while (t < s) {
        if(*t != *s) {
            flag = 0;
            break;
        }
        t++;
        s--;
    }
    printf("%d\n", flag);
    return 0;
}