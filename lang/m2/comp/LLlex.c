/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 * Author: Ceriel J.H. Jacobs
 */

/* L E X I C A L   A N A L Y S E R   F O R   M O D U L A - 2 */

/* $Header$ */

#include	"debug.h"
#include	"idfsize.h"
#include	"numsize.h"
#include	"strsize.h"

#include	<alloc.h>
#include	<em_arith.h>
#include	<em_label.h>
#include	<assert.h>

#include	"LLlex.h"
#include	"input.h"
#include	"f_info.h"
#include	"Lpars.h"
#include	"class.h"
#include	"idf.h"
#include	"def.h"
#include	"type.h"
#include	"const.h"
#include	"warning.h"

long str2long();

t_token		dot,
		aside;
t_type		*toktype;
int		idfsize = IDFSIZE;
int		ForeignFlag;
#ifdef DEBUG
extern int	cntlines;
#endif

static int	eofseen;
extern char	options[];

STATIC
SkipComment()
{
	/*	Skip Modula-2 comments (* ... *).
		Note that comments may be nested (par. 3.5).
	*/
	register int ch;
	register int CommentLevel = 0;

	LoadChar(ch);
	if (ch == '$') {
		LoadChar(ch);
		switch(ch) {
		case 'F':
			/* Foreign; This definition module has an
			   implementation in another language.
			   In this case, don't generate prefixes in front
			   of the names. Also, don't generate call to
			   initialization routine.
			*/
			ForeignFlag = D_FOREIGN;
			break;
		case 'R':
			/* Range checks, on or off */
			LoadChar(ch);
			if (ch == '-') {
				options['R'] = 1;
				break;
			}
			if (ch == '+') {
				options['R'] = 0;
				break;
			}
			/* fall through */
		default:
			PushBack();
			break;
		}
	}
	for (;;) {
		if (class(ch) == STNL) {
			LineNumber++;
#ifdef DEBUG
			cntlines++;
#endif
		}
		else if (ch == '(') {
			LoadChar(ch);
			if (ch == '*') CommentLevel++;
			else continue;
		}
		else if (ch == '*') {
			LoadChar(ch);
			if (ch == ')') {
				CommentLevel--;
				if (CommentLevel < 0) break;
			}
			else continue;
		}
		else if (ch == EOI) {
			lexerror("unterminated comment");
			break;
		}
		LoadChar(ch);
	}
}

STATIC struct string *
GetString(upto)
{
	/*	Read a Modula-2 string, delimited by the character "upto".
	*/
	register int ch;
	register struct string *str = (struct string *)
			Malloc((unsigned) sizeof(struct string));
	register char *p;
	register int len;
	
	len = ISTRSIZE;
	str->s_str = p = Malloc((unsigned int) ISTRSIZE);
	while (LoadChar(ch), ch != upto)	{
		if (class(ch) == STNL)	{
			lexerror("newline in string");
			LineNumber++;
#ifdef DEBUG
			cntlines++;
#endif
			break;
		}
		if (ch == EOI)	{
			lexerror("end-of-file in string");
			break;
		}
		*p++ = ch;
		if (p - str->s_str == len)	{
			str->s_str = Realloc(str->s_str,
				(unsigned int) len + RSTRSIZE);
			p = str->s_str + len;
			len += RSTRSIZE;
		}
	}
	str->s_length = p - str->s_str;
	while (p - str->s_str < len) *p++ = '\0';
	if (str->s_length == 0) str->s_length = 1;
	/* ??? string length at least 1 ??? */
	return str;
}

static char *s_error = "illegal line directive";

STATIC int
getch()
{
	register int ch;

	for (;;) {
		LoadChar(ch);
		if ((ch & 0200) && ch != EOI) {
			error("non-ascii '\\%03o' read", ch & 0377);
			continue;
		}
		break;
	}
	if (ch == EOI) {
		eofseen = 1;
		return '\n';
	}
	return ch;
}

CheckForLineDirective()
{
	register int ch = getch();
	register int	i = 0;
	char		buf[IDFSIZE + 2];
	register char	*c = buf;


	if (ch != '#') {
		PushBack();
		return;
	}
	do {	/*
		 * Skip to next digit
		 * Do not skip newlines
		 */
		ch = getch();
		if (class(ch) == STNL) {
			LineNumber++;
			error(s_error);
			return;
		}
	} while (class(ch) != STNUM);
	while (class(ch) == STNUM)  {
		i = i*10 + (ch - '0');
		ch = getch();
	}
	while (ch != '"' && class(ch) != STNL) ch = getch();
	if (ch == '"') {
		c = buf;
		do {
			*c++ = ch = getch();
			if (class(ch) == STNL) {
				LineNumber++;
				error(s_error);
				return;
			}
		} while (ch != '"');
		*--c = '\0';
		do {
			ch = getch();
		} while (class(ch) != STNL);
		/*
		 * Remember the file name
		 */
		if (!eofseen && strcmp(FileName,buf)) {
			FileName = Salloc(buf,(unsigned) strlen(buf) + 1);
		}
	}
	if (eofseen) {
		error(s_error);
		return;
	}
	LineNumber = i;
}

int
LLlex()
{
	/*	LLlex() is the Lexical Analyzer.
		The putting aside of tokens is taken into account.
	*/
	register t_token *tk = &dot;
	char buf[(IDFSIZE > NUMSIZE ? IDFSIZE : NUMSIZE) + 2];
	register int ch, nch;

	toktype = error_type;

	if (ASIDE)	{	/* a token is put aside		*/
		*tk = aside;
		ASIDE = 0;
		return tk->tk_symb;
	}

again1:
	if (eofseen) {
		eofseen = 0;
		ch = EOI;
	}
	else {
again:
		LoadChar(ch);
		if ((ch & 0200) && ch != EOI) {
			error("non-ascii '\\%03o' read", ch & 0377);
			goto again;
		}
	}

	tk->tk_lineno = LineNumber;

	switch (class(ch))	{

	case STNL:
		LineNumber++;
#ifdef DEBUG
		cntlines++;
#endif
		CheckForLineDirective();
		goto again1;

	case STSKIP:
		goto again;

	case STGARB:
		if ((unsigned) ch - 040 < 0137)	{
			lexerror("garbage char %c", ch);
		}
		else	lexerror("garbage char \\%03o", ch);
		goto again;

	case STSIMP:
		if (ch == '(')	{
			LoadChar(nch);
			if (nch == '*')	{
				SkipComment();
				goto again;
			}
			else if (nch == EOI) eofseen = 1;
			else PushBack();
		}
		if (ch == '&') return tk->tk_symb = AND;
		if (ch == '~') return tk->tk_symb = NOT;
		return tk->tk_symb = ch;

	case STCOMP:
		LoadChar(nch);
		switch (ch)	{

		case '.':
			if (nch == '.')	{
				return tk->tk_symb = UPTO;
			}
			break;

		case ':':
			if (nch == '=')	{
				return tk->tk_symb = BECOMES;
			}
			break;

		case '<':
			if (nch == '=')	{
				return tk->tk_symb = LESSEQUAL;
			}
			if (nch == '>') {
				return tk->tk_symb = '#';
			}
			break;

		case '>':
			if (nch == '=')	{
				return tk->tk_symb = GREATEREQUAL;
			}
			break;

		default :
			crash("(LLlex, STCOMP)");
		}
		if (nch == EOI) eofseen = 1;
		else PushBack();
		return tk->tk_symb = ch;

	case STIDF:
	{
		register char *tag = &buf[0];
		register t_idf *id;

		do	{
			if (tag - buf < idfsize) *tag++ = ch;
			LoadChar(ch);
		} while(in_idf(ch));

		if (ch == EOI) eofseen = 1;
		else PushBack();
		*tag++ = '\0';

		tk->TOK_IDF = id = str2idf(buf, 1);
		return tk->tk_symb = id->id_reserved ? id->id_reserved : IDENT;
	}

	case STSTR: {
		register struct string *str = GetString(ch);

		if (str->s_length == 1) {
			tk->TOK_INT = *(str->s_str) & 0377;
			toktype = char_type;
			free(str->s_str);
			free((char *) str);
		}
		else {
			tk->tk_data.tk_str = str;
			toktype = standard_type(T_STRING, 1, str->s_length);
		}
		return tk->tk_symb = STRING;
		}

	case STNUM:
	{
		/*	The problem arising with the "parsing" of a number
			is that we don't know the base in advance so we
			have to read the number with the help of a rather
			complex finite automaton.
		*/
		enum statetp {Oct,OptHex,Hex,Dec,OctEndOrHex,End,OptReal,Real};
		register enum statetp state;
		register int base;
		register char *np = &buf[1];
					/* allow a '-' to be added	*/

		buf[0] = '-';
		*np++ = ch;
		state = is_oct(ch) ? Oct : Dec;
		LoadChar(ch);
		for (;;) {
			switch(state) {
			case Oct:
				while (is_oct(ch))	{
					if (np < &buf[NUMSIZE]) *np++ = ch;
					LoadChar(ch);
				}
				if (ch == 'B' || ch == 'C') {
					base = 8;
					state = OctEndOrHex;
					break;
				}
				/* Fall Through */
			case Dec:
				base = 10;
				while (is_dig(ch))	{
					if (np < &buf[NUMSIZE]) {
						*np++ = ch;
					}
					LoadChar(ch);
				}
				if (ch == 'D') state = OptHex;
				else if (is_hex(ch)) state = Hex;
				else if (ch == '.') state = OptReal;
				else {
					state = End;
					if (ch == 'H') base = 16;
					else if (ch == EOI) eofseen = 1;
					else PushBack();
				}
				break;

			case OptHex:
				LoadChar(ch);
				if (is_hex(ch)) {
					if (np < &buf[NUMSIZE]) *np++ = 'D';
					state = Hex;
				}
				else	state = End;
				break;

			case Hex:
				while (is_hex(ch))	{
					if (np < &buf[NUMSIZE]) *np++ = ch;
					LoadChar(ch);
				}
				base = 16;
				state = End;
				if (ch != 'H') {
					lexerror("H expected after hex number");
					if (ch == EOI) eofseen = 1;
					else PushBack();
				}
				break;

			case OctEndOrHex:
				if (np < &buf[NUMSIZE]) *np++ = ch;
				LoadChar(ch);
				if (ch == 'H') {
					base = 16;
					state = End;
					break;
				}
				if (is_hex(ch)) {
					state = Hex;
					break;
				}
				if (ch == EOI) eofseen = 1;
				else PushBack();
				ch = *--np;
				*np++ = '\0';
				base = 8;
				/* Fall through */
				
			case End:
				*np = '\0';
				if (np >= &buf[NUMSIZE]) {
					tk->TOK_INT = 1;
					lexerror("constant too long");
				}
				else {
					np = &buf[1];
					while (*np == '0') np++;
					tk->TOK_INT = str2long(np, base);
					if (strlen(np) > 14 /* ??? */ ||
				    	    tk->TOK_INT < 0) {
lexwarning(W_ORDINARY, "overflow in constant");
					}
				}
				if (ch == 'C' && base == 8) {
					toktype = char_type;
					if (tk->TOK_INT<0 || tk->TOK_INT>255) {
lexwarning(W_ORDINARY, "character constant out of range");
					}
				}
				else if (ch == 'D' && base == 10) {
					toktype = longint_type;
				}
				else if (tk->TOK_INT>=0 &&
					 tk->TOK_INT<=max_int) {
					toktype = intorcard_type;
				}
				else	toktype = card_type;
				return tk->tk_symb = INTEGER;

			case OptReal:
				/*	The '.' could be the first of the '..'
					token. At this point, we need a
					look-ahead of two characters.
				*/
				LoadChar(ch);
				if (ch == '.') {
					/*	Indeed the '..' token
					*/
					PushBack();
					PushBack();
					state = End;
					base = 10;
					break;
				}
				state = Real;
				break;
			}
			if (state == Real) break;
		}

		/* a real real constant */
		if (np < &buf[NUMSIZE]) *np++ = '.';

		toktype = real_type;

		while (is_dig(ch)) {
			/* 	Fractional part
			*/
			if (np < &buf[NUMSIZE]) *np++ = ch;
			LoadChar(ch);
		}

		if (ch == 'E' || ch == 'D') {
			/*	Scale factor
			*/
			if (ch == 'D') {
				toktype = longreal_type;
				LoadChar(ch);
				if (!(ch == '+' || ch == '-' || is_dig(ch)))
					goto noscale;
			}
			if (np < &buf[NUMSIZE]) *np++ = 'E';
			LoadChar(ch);
			if (ch == '+' || ch == '-') {
				/*	Signed scalefactor
				*/
				if (np < &buf[NUMSIZE]) *np++ = ch;
				LoadChar(ch);
			}
			if (is_dig(ch)) {
				do {
					if (np < &buf[NUMSIZE]) *np++ = ch;
					LoadChar(ch);
				} while (is_dig(ch));
			}
			else {
				lexerror("bad scale factor");
			}
		}

noscale:
		*np++ = '\0';
		if (ch == EOI) eofseen = 1;
		else PushBack();

		if (np >= &buf[NUMSIZE]) {
			tk->TOK_REL = Salloc("0.0", 5);
			lexerror("floating constant too long");
		}
		else	tk->TOK_REL = Salloc(buf, (unsigned) (np - buf)) + 1;
		return tk->tk_symb = REAL;

		/*NOTREACHED*/
	}

	case STEOI:
		return tk->tk_symb = -1;

	case STCHAR:
	default:
		crash("(LLlex) Impossible character class");
		/*NOTREACHED*/
	}
	/*NOTREACHED*/
}
