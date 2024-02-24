/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 */

#include <stb.h>

#define CRAYFLOAT

/*
 * machine dependent back end routines for the Cray X-MP
 */

void
con_part(int sz, word w) {
	word b;
	int left_shift;
	int right_shift;

	right_shift = sz * 8;
        left_shift  = (8 - part_size) * 8;
	while (right_shift > 0) {
		if (part_size == TEM_WSIZE) part_flush();
		right_shift -= 8;
		b = (w >> right_shift) & 0xff;
		part_size += 1;
		left_shift -= 8;
		part_word |= b << left_shift;
	}
}

void
con_mult(word sz) {

	if (sz != 8)
		fatal("bad icon/ucon size");
	fprintf(codefile,"con %s\n", str);
}

#define CODE_GENERATOR  
#define FL_MSL_AT_LOW_ADDRESS	1
#define FL_MSW_AT_LOW_ADDRESS	1
#define FL_MSB_AT_LOW_ADDRESS	1
#include <con_float>

#ifdef REGVARS
full lbytes;
#endif

void
prolog(full nlocals) {
	full incr;

	incr = (nlocals + 7) / 8;
	fprintf(codefile, "lc a1,%ld\n", incr + 8);
	fputs("isub a1,a7,a1\n", codefile);
	fputs("isub a0,a5,a1\n", codefile);
	fputs("jap @estack\n", codefile);
	fputs("push a6\n", codefile);
	fputs("tr a6,b00\n", codefile);
	fputs("push a6\n", codefile);
	fputs("tr a6,a7\n", codefile);
#ifdef REGVARS
	lbytes = nlocals;
#else
	if (nlocals > 0) {
		if (incr < 3) {
			while (incr-- > 0) fputs("dcra a7\n", codefile);
		}
		else {
			fprintf(codefile, "lc a1,%ld\n", incr);
			fputs("isub a7,a7,a1\n", codefile);
		}
	}
#endif
}

#ifdef REGVARS
int
regscore(long off, int size, int typ, int score, int totyp)
{
	return score;
}

void
i_regsave()
{
}

void
f_regsave()
{
}

void
regsave(const char* regstr, long off, int size)
{
}

void
regreturn()
{
}
#endif /* REGVARS */

#ifdef MACH_OPTIONS
void
mach_option(s)
	char *s;
{
}
#endif /* MACH_OPTIONS */

void mes(type) word type;
{
        int argt;

        switch ((int)type)
        {
                case ms_ext:
                        for (;;)
                        {
                                switch (argt = getarg(ptyp(sp_cend) | ptyp(sp_pnam) | sym_ptyp))
                                {
                                        case sp_cend:
                                                return;
                                        default:
                                                strarg(argt);
                                                fprintf(codefile, "entry %s\n", argstr);
                                                break;
                                }
                        }
                default:
                        while (getarg(any_ptyp) != sp_cend)
                                ;
                        break;
        }
}


char    *segname[] = {
	"text: section code",        /* SEGTXT */
	"data: section data",        /* SEGCON */
	"rom:  section data",        /* SEGROM */
	"bss:  section data"         /* SEGBSS */
};
