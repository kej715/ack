/*
 * (c) copyright 1989 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header$ */
/*	C O N S T A N T   E X P R E S S I O N   H A N D L I N G		*/
/*	  F O R   F L O A T I N G   P O I N T   N U M B E R S		*/

#include	"debug.h"
#include	"assert.h"
#include	<alloc.h>
#include	"target_sizes.h"
#include	"idf.h"
#include	<flt_arith.h>
#include	"arith.h"
#include	"type.h"
#include	"label.h"
#include	"expr.h"
#include	"sizes.h"
#include	"Lpars.h"

extern int ResultKnown;
extern char *symbol2str();

fltcstbin(expp, oper, expr)
	register struct expr **expp, *expr;
{
	/*	The operation oper is performed on the constant
		expressions *expp(ld) and expr(ct), and the result restored in
		*expp.
	*/
	flt_arith o1, o2;
	int compar = 0;
	arith cmpval;

	o1 = (*expp)->FL_ARITH;
	o2 = expr->FL_ARITH;

	ASSERT(is_fp_cst(*expp) && is_fp_cst(expr));
	switch (oper)	{
	case '*':
		flt_mul(&o1, &o2, &o1);
		break;
	case '/':
		flt_div(&o1, &o2, &o1);
		break;
	case '+':
		flt_add(&o1, &o2, &o1);
		break;
	case '-':
		flt_sub(&o1, &o2, &o1);
		break;
	case '<':
	case '>':
	case LESSEQ:
	case GREATEREQ:
	case EQUAL:
	case NOTEQUAL:
		compar++;
		cmpval = flt_cmp(&o1, &o2);
		switch(oper) {
		case '<':	cmpval = (cmpval < 0);	break;
		case '>':	cmpval = (cmpval > 0);	break;
		case LESSEQ:	cmpval = (cmpval <= 0);	break;
		case GREATEREQ:	cmpval = (cmpval >= 0);	break;
		case EQUAL:	cmpval = (cmpval == 0);	break;
		case NOTEQUAL:	cmpval = (cmpval != 0);	break;
		}
		break;
	case '%':
	case LEFT:
	case RIGHT:
	case '&':
	case '|':
	case '^':
		/*
		expr_error(*expp, "floating operand for %s", symbol2str(oper));
		break;
		*/
	default:
		crash("(fltcstoper) bad operator %s", symbol2str(oper));
		/*NOTREACHED*/
	}

	switch (flt_status) {
		case 0:
		case FLT_UNFL:
			break;
		case FLT_OVFL:
			if (!ResultKnown)
			    expr_warning(expr,"floating point overflow on %s"
					, symbol2str(oper));
			break;
		case FLT_DIV0:
			if (!ResultKnown)
				expr_error(expr,"division by 0.0");
			else
				expr_warning(expr,"division by 0.0");
			break;
		default:	/* there can't be another status */
			crash("(fltcstoper) bad status");
	}
	if ((*expp)->FL_VALUE) free((*expp)->FL_VALUE);
	(*expp)->FL_VALUE = 0;
	if (compar) {
		fill_int_expr(*expp, cmpval, INT);
	} else {
		(*expp)->FL_ARITH = o1;
	}
	(*expp)->ex_flags |= expr->ex_flags;
	(*expp)->ex_flags &= ~EX_PARENS;
	free_expression(expr);
}