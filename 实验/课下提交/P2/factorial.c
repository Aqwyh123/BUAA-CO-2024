#include <stdio.h>
#include <string.h>

#define LEN 1004

void read(int a[]);
void print(int a[]);
void move(int a[], int b[]);
void mul(int a[], int b[], int c[]);
void sub_one(int a[], int c[]);
int is_zero(int a[]);

int main()
{
    int n[LEN] = { 0 }, temp[LEN] = { 0 }, result[LEN] = { 1 }, one[LEN] = { 1 };
    read(n);
    while (is_zero(n) == 0) {
        mul(n, result, temp);
        move(result, temp);
        sub_one(n, temp);
        move(n, temp);
    }
    print(result);
    return 0;
}

void clear(int a[])
{
    for (int i = 0; i < LEN; ++i) a[i] = 0;
}

void read(int a[])
{
    static char s[LEN + 1];
    scanf("%s", s);

    clear(a);

    int len = strlen(s);
    for (int i = 0; i < len; ++i) a[len - i - 1] = s[i] - '0';
}

void print(int a[])
{
    int i;
    for (i = LEN - 1; i >= 1; --i)
        if (a[i] != 0) break;
    for (; i >= 0; --i) putchar(a[i] + '0');
    putchar('\n');
}

void sub_one(int a[], int c[])
{
    clear(c);
    int b[LEN] = { 1 };
    for (int i = 0; i < LEN - 1; ++i) {
        c[i] += a[i] - b[i];
        if (c[i] < 0) {
            c[i + 1] -= 1;
            c[i] += 10;
        }
    }
}

void mul(int a[], int b[], int c[])
{
    clear(c);

    for (int i = 0; i < LEN - 1; ++i) {
        for (int j = 0; j <= i; ++j) c[i] += a[j] * b[i - j];

        if (c[i] >= 10) {
            c[i + 1] += c[i] / 10;
            c[i] %= 10;
        }
    }
}

void move(int a[], int b[])
{
    for (int i = 0; i < LEN; ++i) a[i] = b[i];
}

int is_zero(int a[])
{
    for (int i = 0; i < LEN; ++i)
        if (a[i] != 0) return 0;
    return 1;
}