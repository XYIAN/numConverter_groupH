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

	int sign = (dec >= 0) * 2 - 1;
	char* pos = out;

	if (sign < 0)
	{
		*pos = '-';
		pos++;
	}
	// this is to force it to be positive for ease of calculation
	dec *= sign;
	int dec_spaces = 0;

	while (dec - (int)dec > 0)
	{
		dec *= base;
		dec_spaces++;
	}

	unsigned val = dec;
	int len = 0;
	while (val > 0)
	{
		val /= base;
		len++;
	}

	int offset = to_exp(base, len - 1);
	val = dec;
	while (len > 0)
	{
		if (len == dec_spaces)
		{
			*pos = '.';
			pos++;
		}
		*pos = conv_vals[(val / offset) % base];
		offset /= base;
		pos++;
		len--;
	}

	*pos = 0;
}

//General to Decimal
float toDecimal(const char *input, int base)
{
	float output = 0;
	int len = 0;
	const char *pos = input;
	int sign = (*pos != '-') * 2 - 1;

	if (sign < 0)
	{
		pos++;
	}

	const char* p = pos;
	while (*p != 0 && *p != '.')
	{
		len++;
		p++;
	}

	// looping through string till end
	float offset = to_exp(base, len - 1);
	while (*pos)
	{
		if (*pos != '.')
		{
			float val = get_val(*pos);
			output += val * offset;
			offset /= base;
		}
		pos++;
	}

	output *= sign;
	return output;
}

void binaryTo(char *out, const char *in, int base)
{
	// persistent vars: opos, in, base, ipos
	int bpd = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch (base)
	{
	case 16:
		bpd++;
	case 8:
		bpd += 2;
	}

	char tmp[129];
	char* tpos = tmp;
	int offset = 0;

	const char* ipos = in;
	char* opos = out;

	if (*ipos == '-')
	{
		*opos = '-';
		opos++;
		ipos++;
	}

	const char* p = ipos;
	int ulen = 0;
	int llen = 0;

	// getting length before decimal
	while (*p)
	{
		if (*p == '.')
		{
			p++;
			break;
		}

		p++;
		ulen++;
	}
	// getting length past decimal
	while (*p)
	{
		p++;
		llen++;
	}

	offset = bpd - (ulen % bpd);
	if (offset == bpd) offset = 0;
	// prepending the tmp array
	while (offset > 0)
	{
		*tpos = '0';
		tpos++;
		offset--;
	}

	while (*ipos)
	{
		*tpos = *ipos;
		tpos++;
		ipos++;
	}

	offset = bpd - (llen % bpd);
	if (offset == bpd) offset = 0;

	while (offset > 0)
	{
		*tpos = '0';
		tpos++;
		offset--;
	}

	*tpos = 0;

	tpos = tmp;
	while (*tpos)
	{
		if (*tpos == '.')
		{
			*opos = '.';
			tpos++;
			opos++;
		}
		else
		{
			p = tpos + bpd - 1;
			int mag = 1;
			int val = 0;

			while (p >= tpos)
			{
				val += get_val(*p) * mag;
				mag *= 2;
				p--;
			}

			*opos = conv_vals[val];
			tpos += bpd;
			opos++;
		}
	}
	*opos = 0;
}

void toBinary(char *out, const char *in, int base)
{
	// persistent vars: opos, base, ipos
	int tmp = 1;
	// janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	switch (base)
	{
	case 16:
		tmp++;
	case 8:
		tmp += 2;
	}
	base = tmp;

	const char* ipos = in;
	char* opos = out;

	if (*ipos == '-')
	{
		*opos = '-';
		opos++;
		ipos++;
	}

	while (*ipos)
	{
		if (*ipos == '.')
		{
			*opos = *ipos;
			opos++;
		}
		else
		{
			int val = get_val(*ipos);
			char* p = opos + base - 1;

			while (val > 0)
			{
				*p = conv_vals[val % 2];
				val /= 2;
				p--;
			}

			while (p >= opos)
			{
				*p = '0';
				p--;
			}
			opos += base;
		}
		ipos++;
	}
	*opos = 0;
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
				toBinary(output_buf, input_buf, inputBase);
				binaryTo(output_buf, output_buf, outputBase);
			}
			cout << "Output: " << output_buf << "\n";
		}
		cout << "\nWould you like to enter another number?(y/n) ";
		cin >> choice;
		cout << "\n";
	}
}