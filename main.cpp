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
 *            v: 2.2.0
 *******************************/

using namespace std;
const char* conv_vals = "0123456789ABCDEF";
int cstr_len(const char* str)
{
	int len = 0;
	const char* pos = str;
	while(*pos)
	{
		pos++;
		len++;
	}
	return len;
}
// getting the value of an individual char
int get_val(char c)
{
	int i = 0;
	for (const char* l = conv_vals; *l; l++)
	{
		if (*l == c) break;
		i++;
	}
	return i;
}
int to_exp(int base, int exp)
{
	int val = 1;
	for (int i = 0; i < exp; i++)
	{
		val *= base;
	}
	return val;
}
//General to decimal method
void decimalTo(char* out, int dec, int base)
{
	char tmp[128];
	int index = 0;
	// if value is zero, return "0" because the loop won't work correctly
	if (dec == 0)
	{
		out[0] = '0';
		out[1] = 0;
		return;
	}
	while (dec > 0)
	{
		// adding chars to tmp string based on popped values from integer
		tmp[index] = conv_vals[dec % base];
		dec /= base;
		index++;
	}
	const char *pos = tmp + index -1 ;
	const char* start = tmp;
	// reversing tmp string and outputting it
	unsigned i = 0;
	while (pos != start - 1)
	{
		out[i] = *pos;
		i++;
		pos--;
	}
	out[i] = 0;
}
//General to Decimal
int toDecimal(const char* input, int base)
{
	int output = 0;
	int len = cstr_len(input);
	const char *pos = input;
	// looping through string till end
	while (*pos)
	{
		// adding value of char to output value
		int val = get_val(*pos);
		output += val * to_exp(base, len - 1);
		len--;
		pos++;
	}
	return output;
}
// base should never be anything other than 8 or 16
void binaryTo(char* out, const char* in, int base)
{
	// getting length of input string
	int len = cstr_len(in);
	int bitsPerDigit = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch(base)
	{
		case 16:
			bitsPerDigit++;
		case 8:
			bitsPerDigit += 2;
	}
	// getting length of output string
	int outputLength = len / bitsPerDigit;
	// if there is a remainder digit, add 1 to output length
	int mod = len % bitsPerDigit;
	if (mod > 0) outputLength++;
	// adding zero to end of string for termination
	int oi = outputLength;
	out[oi--] = 0;
	int val = 0;
	int counter = 0;
	// looping through input
	for (int i = len - 1; i >= 0; i--)
	{
		// grouping the bits of the binary string together to find value of char
		int bbi = counter % bitsPerDigit;
		val += get_val(in[i]) << bbi;
		// if loop is finished or finished with most recent group of bits
		if (bbi == bitsPerDigit - 1 || i == 0)
		{
			// adding char to string and incrementing
			out[oi] = conv_vals[val];
			oi--;
			val = 0;
		}
		counter++;
	}
}
void toBinary(char *out, const char* in, int base)
{
	int bitsPerDigit = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch(base)
	{
		case 16:
			bitsPerDigit++;
		case 8:
			bitsPerDigit += 2;
	}
	int len = cstr_len(in);
	int outputLength = len * bitsPerDigit;
	int oi = outputLength;
	out[oi--] = 0;
	for (const char* c = in + len - 1; c >= in; c--)
	{
		int val = get_val(*c);
		int count = 0;
		while (val > 0)
		{
			out[oi] = conv_vals[val % 2];
			val /= 2;
			oi--;
			count++;
		}
		// filling in the extra space
		for (int i = 0; i < (bitsPerDigit - count); i++)
		{
			out[oi--] = '0';
		}
	}
}


bool base_valid(int base)
{
	return base == 2 || base == 8 || base == 10 || base == 16;
}

int main()
{
	char input_buf[128];
	char output_buf[128];
    char choice = 'Y';
    while(choice == 'Y'){//loop added to convert multiple numbers 
	int inputBase = -1;
	int outputBase = -1;
	
	cout <<endl<< "     Group H - CST237" <<endl<<"Welcome to the base converter!\n\nEnter a number: ";
	cin >> input_buf;

ask_input_base:

	cout << "Enter the base of the input (2, 8, 10, or 16): ";
	cin >> inputBase;
	cout << "\n";

	if(!base_valid(inputBase))
	{
		cout << "Invalid base!\n\n";
		goto ask_input_base;
	}
	while(1)
	{
		cout <<endl<< "Enter the desired output base (2, 8, 10, or 16) or negative number to exit: ";
		cin >> outputBase;
		if (outputBase < 0) break;
		if (!base_valid(outputBase))
		{
			cout << "Invalid base!\n\n";
			continue;
		}
		int val;
		if(inputBase == 10 || outputBase == 10)
		{
			decimalTo(output_buf, toDecimal(input_buf, inputBase), outputBase);
		}
		else
		{
			char tmp[128];
			toBinary(tmp, input_buf, inputBase);
			binaryTo(output_buf, tmp, outputBase);
		}

		cout << "Output: " << output_buf << "\n\nWould you like to convert to a new base?(Y/N)";
        char breakMe = 'N';
        cin >> breakMe ;
        if(breakMe == 'N'){break;} 	
        
	}
    cout <<endl<< "Would you like to enter another number?(Y/N)" ;
    cin >> choice;  
    }//end outer number loop
    cout <<endl<< "No further conversions requested..\n      Now Exiting, Goodbye! :) "<<endl;
}