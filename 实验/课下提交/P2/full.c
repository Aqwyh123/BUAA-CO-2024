#include <stdio.h>
#include <stdlib.h>

char space[2] = " ", enter[2] = "\n";
int symbol[7], array[7];
int n;

void fullArray(int index);

int main()
{
    scanf("%d", &n);
    fullArray(0);
    return 0;
}

void fullArray(int index)
{
    if (index >= n) {
        for (int i = 0; i < n; i++) {
            int *p = array;
            p += i;
            printf("%d", *p);
            printf(space);
        }
        printf(enter);
        return;
    }
    for (int i = 0; i < n; i++) {
        int *p = symbol;
        p += i;
        int temp = *p;
        if (temp == 0) {
            p = array;
            p += index;
            temp = i + 1;
            *p = temp;
            p = symbol;
            p += i;
            temp = 1;
            *p = temp;
            fullArray(index + 1);
            temp = 0;
            *p = temp;
        }
    }
}