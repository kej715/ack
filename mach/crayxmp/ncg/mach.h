/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
#ifndef NORCSID
#define ID_MH		"$Id$"
#endif

#define ex_ap(y)        fprintf(codefile,"entry %s\n",y)
#define in_ap(y)

#define newilb(x)       fprintf(codefile,"%s:\n",x)
#define newdlb(x)       fprintf(codefile,"%s: = w.*\n",x)
#define newplb(x)       fprintf(codefile,"%s: bss 0\n", x)
#define dlbdlb(x,y)     fprintf(codefile,"%s: = %s\n",x,y)
#define newlbss(l,x)    fprintf(codefile,"%s: = w.*\nbssz %ld\n",l,((x)+7)/8);

#define cst_fmt         "X'%016lX"
#define off_fmt         "%ld"
#define ilb_fmt         "I%x@%x"
#define dlb_fmt         "D%x"
#define hol_fmt         "hol%d"

#define hol_off         "%ld+hol%d"

#define con_cst(x)      fprintf(codefile,"con X'%016lX\n",x)
#define con_ilb(x)      fprintf(codefile,"ilb %s\n",x)
#define con_dlb(x)      fprintf(codefile,"dlb %s\n",x)

#define fmt_id(fr,to)	sprintf(to, "@%s", fr);strrep(to, '_', '%')

#define BSS_INIT        0
#define MACH_OPTIONS
