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

//new functions for req 

//convert decimal 
int convertDecimal(int num){
    int convertStatus; 
    cout << "What would you like to convert the decimal " << num << " to?" <<
    endl<< "(1=Decimal) (2=Binary) (3=Octal) (4=Hexidecimal) (0=exit)::";
    cin >> convertStatus; 
    if(convertStatus == 0){
        return 0;
    }else if(convertStatus == 1){
        return num;
    }
    return 0; 

}


int main()
{
	int num, inputType;
	char buf[65];
    
    string choice = "Y";
    while(choice == "Y"){
        cout << "\nWhat type of number would you like to convert?" <<
        endl << "(1=Decimal) (2=Binary) (3=Octal) (4=Hexidecimal) \n(0=exit) "; 
        cin >> inputType; 

        printf("Enter a number: ");
	    scanf("%d", &num);
        if(inputType == 0){
            cout << "You entered 0, exit status" << endl; 
            break; 
        }else if(inputType == 1){
            cout << "You entered 1, decimal status" << endl; 
        }else if(inputType == 2){
            cout << "You entered 2, binary status" << endl;
        }else if(inputType == 3){
            cout << "You entered 3, octal status" << endl;
        }else if(inputType == 4){
            cout << "You entered 4, hexidecimal status" << endl;
        }
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
    cout << "Program exiting...goodbye!"<<endl; 
	
	return 0;
}