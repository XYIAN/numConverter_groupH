#include <iostream>
#include <stdio.h>
/*******************************
 *	Authors: Nicole Weber, Jennifer Lopez, Kyle Dillbeck, Isaac Hirzel
 *	CST237 Project c prototype
 *  group H project 3
 *******************************/
void convert_base(char *out, int num, int base)
{
	int index = 0;
	while(num > 0)
	{

		out[index] = "0123456789ABCDEF"[num % base];
		num /= base;
		index++;
	}

	char *pos = out + index -1 ;
	while (*pos)
	{
		putchar(*pos);
		pos--;
	}
	putchar('\n');
}

int main()
{
	int num;
	char buf[65];
	printf("Enter a number: ");
	scanf("%d", &num);
	convert_base(buf, num, 2);
	convert_base(buf, num, 3);
	convert_base(buf, num, 8);
	convert_base(buf, num, 16);
	return 0;
}