/*******************************
 *	    Authors: Kyle Dillbeck, Isaac Hirzel, Jennifer Lopez, Nicole Weber
 *	      Title: CST237 Project c prototype
 *  Description: group H project 3
 *         Date: 11/17/20
 *            v: 2.2.0
 *******************************/
#include <iostream>

using namespace std;

const char *conv_vals = "0123456789ABCDEF";

int cstr_len(const char *str)
{
	int len = 0;
	const char *pos = str;
	while (*pos)
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
	for (const char *l = conv_vals; *l; l++)
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

void decimalTo(char *out, float dec, int base)
{
	if (dec == 0.0)
	{
		out[0] = '0';
		out[1] = 0;
		return;
	}

	int sign = (dec > 0) * 2 - 1;

	char* pos = out;
	if (dec < 0)
	{
		*pos = '-';
		pos++;
	}
	// this is to assure that it is a positive number
	dec *= sign;

	unsigned upper;
	upper = dec;
	dec -= (float)upper;
	int len = 0;
	unsigned ut = upper;

	while (ut > 0)
	{
		ut /= base;
		len++;
	}

	int offs = to_exp(base, len - 1);
	while (len > 0)
	{
		*pos++ = conv_vals[(upper / offs) %base];
		offs /= base;
		len--;
	}

	if (dec > 0)
	{
		*pos++ = '.';
		while(dec - (int)dec > 0)
		{
			char c = conv_vals[(int)((dec - (int)dec) * base)];
			*pos++ = c;
			dec *= base;
		}
	}
	*pos = 0;
}

//General to Decimal
float toDecimal(const char *input, int base)
{
	int dec_spaces = 0;
	float output = 0;
	int len = cstr_len(input);
	const char *pos = input;
	int sign = (*pos != '-') * 2 - 1;
	if (sign < 0)
	{
		pos++;
		len--;
	}
	// looping through string till end
	int offset = to_exp(base, len - 1);
	while (*pos)
	{
		if (*pos == '.')
		{
			dec_spaces = len;
		}
		else
		{
			float val = get_val(*pos);
			output += val * offset;
			offset /= base;
			len--;
		}
		pos++;
	}
	output /= to_exp(base, dec_spaces);

	output *= sign;
	return output;
}
// base should never be anything other than 8 or 16
void binaryTo(char *out, const char *in, int base)
{
	// getting length of input string
	int bitsPerDigit = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch (base)
	{
	case 16:
		bitsPerDigit++;
	case 8:
		bitsPerDigit += 2;
	}

	bool is_neg = false;
	if (in[0] == '-')
	{
		is_neg = true;
		out[0] = '-';
		out++;
		in++;
	}

	// getting length of output string
	int len = cstr_len(in);
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
	if (is_neg) out--;
}
void toBinary(char *out, const char *in, int base)
{
	int bitsPerDigit = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch (base)
	{
	case 16:
		bitsPerDigit++;
	case 8:
		bitsPerDigit += 2;
	}

	bool is_neg = false;
	if (in[0] == '-')
	{
		is_neg = true;
		out[0] = '-';
		out++;
		in++;
	}

	int len = cstr_len(in);
	int outputLength = len * bitsPerDigit;
	int oi = outputLength;
	out[oi--] = 0;

	for (const char *c = in + len - 1; c >= in; c--)
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
	if (is_neg) out--;
}

bool base_valid(int base)
{
	return base == 2 || base == 8 || base == 10 || base == 16;
}

int main()
{
	char input_buf[128];
	char output_buf[128];

	cout << "Welcome to the base converter!\n\n";
	char choice = 'y';

	while(choice == 'Y' || choice == 'y')
	{
		cout << "Enter a number: ";
		int inputBase = -1;
		int outputBase = -1;

		cin >> input_buf;
		cout << '\n';
		int len = cstr_len(input_buf);

		int min_base = 0;
		bool valid_input = true;

		int i = 0;
		if (input_buf[0] == '-') i = 1;
		bool has_dec = false;
		for (i; i < len; i++)
		{
			if (input_buf[i] == '.')
			{
				if (has_dec)
				{
					valid_input = false;
					break;
				}
				has_dec = true;
				continue;
			}
			int v = get_val(input_buf[i]);
			if (v >= 16)
			{
				valid_input = false;
			}
			if (v + 1 > min_base) min_base = v + 1;
		}

		if (!valid_input)
		{
			std::cout << "Input contains invalid digits!\n\n";
			continue;
		}

	ask_input_base:

		cout << "Enter the base of the input (2, 8, 10, or 16): ";
		cin >> inputBase;

		if (!base_valid(inputBase))
		{
			cout << "Invalid base!\n\n";  
			goto ask_input_base;
		}

		if (inputBase < min_base)
		{
			cout << "Input contains digits of a higher base than specified!\n\n";
			goto ask_input_base;
		}

		while (1)
		{
			cout << "\nEnter the desired output base (2, 8, 10, or 16) or negative number to exit: ";
			cin >> outputBase;
			if (outputBase < 0)
			{
				break;
			}
			else if (!base_valid(outputBase))
			{
				cout << "Invalid base!\n\n";
				continue;
			}

			int val;
			if (inputBase == 10 || outputBase == 10)
			{
				decimalTo(output_buf, toDecimal(input_buf, inputBase), outputBase);
			}
			else
			{
				char tmp[128];
				toBinary(tmp, input_buf, inputBase);
				binaryTo(output_buf, tmp, outputBase);
			}
			cout << "Output: " << output_buf << "\n";
		}
		cout << "\nWould you like to enter another number?(y/n) ";
		cin >> choice;
		cout << "\n";
	}
}