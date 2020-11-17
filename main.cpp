#include <iostream> 
#include <iomanip>
#include <cmath>
#include <vector>
#include <string>
#include <algorithm>
#include <cctype>
#include <cstring>
#include <cstdio>
#include <stdio.h>
#include <ctype.h>
#include <stack>
#include <limits.h>
#include <unordered_map>
using namespace std;
/*******************************
 *	    Authors: Kyle Dillbeck, Isaac Hirzel, Jennifer Lopez, Nicole Weber
 *	      Title: CST237 Project c prototype
 *  Description: group H project 3
 *         Date: 11/17/20
 *            v: 1.2.0
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
    cout << "What type of number would you like to convert?" <<
    endl << "  (1=Decimal) (2=Binary) (3=Octal) (4=Hexidecimal)"<<
    endl; 
    string choice = "Y";
    while(choice == "Y"){
        printf("Enter a number: ");
	    scanf("%d", &num);

        //convert to dec from dec
        //convert to dec from binary
        //convert to dec from oct
        //convert to dec from hex

        //convert to binary from dec
        //convert to binary from binary
        //convert to binary from oct
        //convert to binary from hex
        
        //convert to oct from dec
        //convert to oct from binary
        //convert to oct from oct
        //convert to oct from hex

        //convert to hex from dec
        //convert to hex from binary
        //convert to hex from oct
        //convert to hex from hex

        convert_base(buf, num, 2);
	    convert_base(buf, num, 3);
	    convert_base(buf, num, 8);
	    convert_base(buf, num, 16);



        cout << "Convert a new number?(Y/N)" << endl; 
        cin >> choice; 
    }
	
	return 0;
}