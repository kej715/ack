/* $Id$ */
/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
 
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "gen.h"
#include "top.h"
#include "queue.h"

/* STANDARD MACHINE-INDEPENT C CODE *************/

static void optimize(void);
static bool try_hashentry(int *, queue);
static int hash(queue);
static void fill_window(queue, int);
static void write_first(queue);
static void set_opcode(instr_p);
static bool check_pattern(patdescr_p, queue);
static bool check_operands(patdescr_p, queue);
static void clear_vars(void);
static bool opmatch(templ_p, const char *);
static bool split_operands(instr_p);
static void labeldef(instr_p);
static bool operand(instr_p, int);
static bool remainder_empty(instr_p);
static char *lstrip(char *, const char *);
static bool rstrip(char *, const char *);
static bool unify(const char *, struct variable *);
static void xform(patdescr_p, queue);
static void replacement(patdescr_p, queue);
static instr_p gen_instr(idescr_p);
static instr_p read_instr(void);
static instr_p newinstr(void);
static void oldinstr(instr_p);
static bool op_separator(instr_p);
static bool well_shaped(const char *);
static bool is_letter(char);
static int is_word_offset(char *s);
static int is_loi8(char *s);
static int is_sti8(char *s);

static struct variable var[NRVARS+1];
static struct variable ANY;  /* ANY symbol matching any instruction */

/* Opcode of first instruction not matched by current pattern */
static char *REST;

#include "gen.c"


/* Macros for efficiency: */

#define is_white(c)	( (c) == ' ' || (c) == '\t')

/* Skip white space in the unprocessed part of instruction 'ip' */
#define skip_white(ip)	while (is_white(*(ip)->rest_line)) (ip)->rest_line++

int main(void)
{
	optimize();
	exit(0);
}


/* Optimize the standard input.
 * The optimizer uses a moving window. The instructions in the current
 * window are matched against a set of patterns generated from the
 * machine description table. If the match fails, the first instruction of
 * the window is moved to a back-up queue and a new instruction is
 * read from the input and appended to the end of the window.
 * If a matching pattern is found (and its operands etc. are ok),
 * the instructions at the head of the window are replaced by new
 * instructions, as indicated in the descriptor table; a new window
 * is created, consisting of the back-up instructions and the new
 * instructions and the rest of the old window. So effectively the
 * window moves a bit to the left after every hit. Hence sequences of
 * optimizations like:
 *	movl r0,x ; cmpl $0,x  -> movl r0,x ; tstl x -> movl r0,x
 * are captured without having a separate pattern for "movl ; cmpl".
 * 
 * Whenever the backup queue exceeds some threshold, its first instruction
 * is written to the output and is removed.
 */

static void optimize(void)
{
	struct queue_t windowq, backupq;
	queue window, backup;
	instr_p ip;

	window = &windowq;
	backup = &backupq;
	empty_queue(window);
	empty_queue(backup);
	fill_window(window,MIN_WINDOW_SIZE);
	while (!empty(window)) {
		if (try_hashentry(hashtab[hash(window)],window) ||
		    try_hashentry(hashany,window)) {
			join_queues(backup,window);
		} else {
			ip = qhead(window);
			remove_head(window);
			add(backup,ip);
			if (qlength(backup) > MIN_WINDOW_SIZE)  {
				write_first(backup);
			}
		}
		fill_window(window,MIN_WINDOW_SIZE);
	}
	while (!empty(backup)) write_first(backup);
}



static bool try_hashentry(int *list, queue window)
{
	int *pp;
	patdescr_p p;

	for (pp = list; *pp != -1; pp++) {
		p = &patterns[*pp];
		if (check_pattern(p,window) &&
		    check_operands(p,window) &&
		    check_constraint(*pp)) {
			xform(p,window);
			return TRUE;
		}
	}
	return FALSE;
}


/* TEMP. */

/* int hash(w)
	queue w;
{
	instr_p ip;

	ip = qhead(w);
	return ip->opc[0] % 31;
}
*/


static int hash(queue w)
{
	char *p;
	int sum,i;
	instr_p ip;

	ip = qhead(w);
/* 	for (sum=0,p=ip->opc;*p;p++)
		sum += *p;
*/

	for (sum=i=0,p=ip->opc;*p;i += 3)
		sum += (*p++)<<(i&03);
	return(sum%128);
}

/* Fill the working window until it contains at least 'len' items.
 * When end-of-file is encountered it may contain fewer items.
 */

static void fill_window(queue w, int len)
{
	instr_p ip;

	while(qlength(w) < len) {
		if ((ip = read_instr()) == NIL) break;
		ip->rest_line = ip->line;
		set_opcode(ip);
		add(w,ip);
	}
}

static void write_first(queue w)
{
	instr_p ip = qhead(w);

	fputs(ip->line, stdout);
	remove_head(w);
	oldinstr(ip);
}


/* Try to recognize the opcode part of an instruction */

static void set_opcode(instr_p ip)
{
	char *p,*q,*qlim;

	if (ip->state == JUNK) return;
	skip_white(ip);
	p = ip->rest_line;
	if (*p == LABEL_STARTER) {
		strcpy(ip->opc,"labdef");
		ip->state = ONLY_OPC;
		return;
	}
	q = ip->opc;
	qlim = q + MAX_OPC_LEN;
	while(*p != OPC_TERMINATOR && *p != '\n') {
		if (q == qlim) {
			ip->state = JUNK;
			return;
		}
		*q++ = *p++;
	}
	*q = '\0';
	ip->rest_line = p;
	ip->state = (well_shaped(ip->opc) ? ONLY_OPC : JUNK);
}



/* Check if pattern 'p' matches the current input */

static bool check_pattern(patdescr_p p, queue w)
{
	idescr_p id_p, idlim;
	instr_p ip;

	ip = qhead(w);
	ANY.vstate = UNINSTANTIATED;
	idlim = &p->pat[p->patlen];
	for (id_p = p->pat; id_p < idlim; id_p++) {
		if (ip == NIL || ip->state == JUNK) return FALSE;
		if (id_p->opcode == (char *) 0) {
			unify(ip->opc,&ANY);
		} else {
			if (strcmp(ip->opc,id_p->opcode) != 0) return FALSE;
		}
		ip = next(ip);
	}
	REST = ip->opc;
	return TRUE;
}



static bool check_operands(patdescr_p p, queue w)
{
	instr_p ip;
	idescr_p id_p;
	int n;

	/* fprintf(stderr,"try pattern %d\n",p-patterns); */
	clear_vars();
	for (id_p = p->pat, ip = qhead(w); id_p < &p->pat[p->patlen];
					  id_p++, ip = next(ip)) {
		assert(ip != NIL);
		if (ip->state == JUNK ||
		    (ip->state == ONLY_OPC && !split_operands(ip))) {
			return FALSE;
		}
		for (n = 0; n < MAXOP; n++) {
			if (!opmatch(&id_p->templates[n],ip->op[n])) {
				return FALSE;
			}
		}
	}
	/* fprintf(stderr,"yes\n"); */
	return TRUE;
}



/* Reset all variables to uninstantiated */

static void clear_vars(void)
{
	int v;

	for (v = 1; v <= NRVARS; v++) var[v].vstate = UNINSTANTIATED;
}


/* See if operand 's' matches the operand described by template 't'.
 * As a side effect, any uninstantiated variables used in the
 * template may become instantiated. For such a variable we also
 * check if it satisfies the constraint imposed on it in the
 * mode-definitions part of the table.
 */

static bool opmatch(templ_p t, const char *s)
{
	char *l, buf[MAXOPLEN+1];
	bool was_instantiated;
	int vno;

	vno = t->varno;
	if (vno == -1 || s[0] == '\0' ) {
		return (vno == -1 && s[0] == '\0');
	}
	was_instantiated = (var[vno].vstate == INSTANTIATED);
	strcpy(buf,s);
	if ( (l=lstrip(buf,t->lctxt)) != NULLSTRING && rstrip(l,t->rctxt)) {
		return (vno == 0 && *l == '\0') ||
		       (vno != 0 && unify(l,&var[vno]) &&
			(was_instantiated || tok_chk(vno)));
	}
	return FALSE;
}



/* Try to recognize the operands of an instruction */

static bool split_operands(instr_p ip)
{
	int i;
	bool res;

	if (strcmp(ip->opc,"labdef") ==0) {
		labeldef(ip);
	} else {
		for (i = 0; operand(ip,i) && op_separator(ip); i++);
	}
	res = remainder_empty(ip);
	ip->state = (res ? DONE : JUNK);
	return res;
}



static void labeldef(instr_p ip)
{
	char *p;
	int oplen;

	p = ip->rest_line;
	while(*p && (*p != LABEL_TERMINATOR)) p++;
	oplen = p - ip->rest_line;
	if (oplen == 0 || oplen > MAXOPLEN) return;
	strncpy(ip->op[0],ip->rest_line,oplen);
	ip->op[0][oplen] = '\0';
	ip->rest_line = ++p;
	return;
}




/* Try to recognize the next operand of instruction 'ip' */

static bool operand(instr_p ip, int n)
{
	char *p;
	int oplen;
#ifdef PAREN_OPEN
	int nesting = 0;
#else
#define nesting 0
#endif

	skip_white(ip);
	p = ip->rest_line;
	while((*p != OP_SEPARATOR || nesting) && *p != '\n') {
#ifdef PAREN_OPEN
		if (strchr(PAREN_OPEN, *p) != 0) nesting++;
		else if (strchr(PAREN_CLOSE, *p) != 0) nesting--;
#endif
		p++;
	}
	oplen = p - ip->rest_line;
	if (oplen == 0 || oplen > MAXOPLEN) return FALSE;
	strncpy(ip->op[n],ip->rest_line,oplen);
	ip->op[n][oplen] = '\0';
	ip->rest_line = p;
	return TRUE;
#ifdef nesting
#undef nesting
#endif
}



/* See if the unprocessed part of instruction 'ip' is empty
 * (or contains only white space).
 */

static bool remainder_empty(instr_p ip)
{
	skip_white(ip);
	return *ip->rest_line == '\n';
}


/* Try to match 'ctxt' at the beginning of string 'str'. If this
 * succeeds then return a pointer to the rest (unmatched part) of 'str'.
 */

static char *lstrip(char *str, const char *ctxt)
{
	assert(ctxt != NULLSTRING);
	while (*str != '\0' && *str == *ctxt) {
		str++;
		ctxt++;
	}
	return (*ctxt == '\0' ? str : NULLSTRING);
}



/* Try to match 'ctxt' at the end of 'str'. If this succeeds then
 * replace truncate 'str'.
 */

static bool rstrip(char *str, const char *ctxt)
{
	char *s;
	const char *c;

	for (s = str; *s != '\0'; s++);
	for (c = ctxt; *c != '\0'; c++);
	while (c >= ctxt) {
		if (s < str || *s != *c--) return FALSE;
		*s-- = '\0';
	}
	return TRUE;
}



/* Try to unify variable 'v' with string 'str'. If the variable
 * was instantiated the unification only succeeds if the variable
 * and the string match; else the unification succeeds and the
 * variable becomes instantiated to the string.
 */

static bool unify(const char *str, struct variable *v)
{
	if (v->vstate == UNINSTANTIATED) {
		v->vstate = INSTANTIATED;
		strcpy(v->value,str);
		return TRUE;
	} else {
		return strcmp(v->value,str) == 0;
	}
}



/* Transform the working window according to pattern 'p' */

static void xform(patdescr_p p, queue w)
{
	instr_p ip;
	int i;

	for (i = 0; i < p->patlen; i++) {
		ip = qhead(w);
		remove_head(w);
		oldinstr(ip);
	}
	replacement(p,w);
}



/* Generate the replacement for pattern 'p' and insert it
 * at the front of the working window.
 * Note that we generate instructions in reverser order.
 */

static void replacement(patdescr_p p, queue w)
{
	idescr_p id_p;

	for (id_p = &p->repl[p->replen-1]; id_p >= p->repl; id_p--) {
		insert(w,gen_instr(id_p));
	}
}



/* Generate an instruction described by 'id_p'.
 * We build a 'line' for the new instruction and call set_opcode()
 * to re-recognize its opcode. Hence generated instructions are treated
 * in exactly the same way as normal instructions that are just read in.
 */

static instr_p gen_instr(idescr_p id_p)
{
	char *opc, *s;
	instr_p ip;
	templ_p t;
	bool islabdef;
	int n;
	static char tmp[] = "x";

	ip = newinstr();
	s = ip->line;
	opc = id_p->opcode;
	if (opc == (char *) 0) opc = ANY.value;
	if (strcmp(opc,"labdef") == 0) {
		islabdef = TRUE;
		s[0] = '\0';
	} else {
		strcpy(s,opc);
		tmp[0] = OPC_TERMINATOR;
		strcat(s,tmp);
		islabdef = FALSE;
	}
	for (n = 0; n < MAXOP;) {
		t = &id_p->templates[n++];
		if (t->varno == -1) break;
		strcat(s,t->lctxt);
		if (t->varno != 0) strcat(s,var[t->varno].value);
		strcat(s,t->rctxt);
		if (n<MAXOP && id_p->templates[n].varno!=-1) {
			tmp[0] = OP_SEPARATOR;
			strcat(s,tmp);
		}
	}
	if (islabdef) {
		tmp[0] = LABEL_TERMINATOR;
		strcat(s,tmp);
	}
	strcat(s,"\n");
	ip->rest_line = ip->line;
	set_opcode(ip);
	return ip;
}



/* Reading and writing instructions.
 * An instruction is assumed to be on one line. The line
 * is copied to the 'line' field of an instruction struct,
 * terminated by a \n and \0. If the line is too long (>MAXLINELEN),
 * it is split into pieces of length MAXLINELEN and the state of
 * each such struct is set to JUNK (so it will not be optimized).
 */

static bool junk_state = FALSE;  /* TRUE while processing a very long line */

static instr_p read_instr(void)
{
	instr_p ip;
	int c;
	char *p, *plim;
	FILE *inp = stdin;

	ip = newinstr();
	plim = &ip->line[MAXLINELEN];
	if (( c = getc(inp)) == EOF) return NIL;
	for (p = ip->line; p < plim;) {
		*p++ = c;
		if (c == '\n') {
			*p = '\0';
			if (junk_state) ip->state = JUNK;
			junk_state = FALSE;
			return ip;
		}
		c = getc(inp);
		if (c == EOF)
			break;
	}
	ungetc(c,inp);
	*p = '\0';
	junk_state = ip->state = JUNK;
	return ip;
}



/* Core allocation.
 * As all instruction struct have the same size we can re-use every struct.
 * We maintain a pool of free instruction structs.
 */

static instr_p instr_pool;
int nr_mallocs = 0; /* for statistics */

static instr_p newinstr(void)
{
	instr_p ip;
	int i;

	if (instr_pool == NIL) {
		instr_pool = (instr_p) malloc(sizeof(struct instruction));
		instr_pool->fw = 0;
		nr_mallocs++;
	}
	assert(instr_pool != NIL);
	ip = instr_pool;
	instr_pool = instr_pool->fw;
	ip->fw = ip->bw = NIL;
	ip->rest_line = NULLSTRING;
	ip->line[0] = ip->opc[0] = '\0';
	ip->state = ONLY_OPC;
	for (i = 0; i < MAXOP; i++) ip->op[i][0] = '\0';
	return ip;
}

static void oldinstr(instr_p ip)
{
	ip->fw = instr_pool;
	instr_pool = ip;
}



/* Low level routines */

static bool op_separator(instr_p ip)
{
	skip_white(ip);
	if (*(ip->rest_line) == OP_SEPARATOR) {
		ip->rest_line++;
		return TRUE;
	} else {
		return FALSE;
	}
}



static bool well_shaped(const char *opc)
{
	return is_letter(opc[0]);
}


static bool is_letter(char c)
{
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

/* is_white(c) : turned into a macro, see beginning of file */

