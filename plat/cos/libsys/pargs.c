#define MAXARGS 100 /* must match definition in boot.s */
#define CCILEN   88

#define STATE_START  0
#define STATE_NEXT   1
#define STATE_STRING 2
#define STATE_END    3

static char argBuf[CCILEN*2 + 1];

/*
 *  _pargs - parse command line arguments
 *
 *  This function parses a control card image to produce a
 *  C-style argument vector.
 */
void _pargs(char *s, int *argc, char *argv[]) {
    char *ap;
    int i;
    char *limit;
    int state;

    i = 0;
    ap = argBuf;
    limit = s + CCILEN;
    state = STATE_START;
    while (s < limit && *s != '\0' && state != STATE_END) {
        switch (state) {
        case STATE_START:
            switch (*s) {
            case ' ':
            case ',':
            case '(':
            case ':':
                s += 1;
                break;
            case ')':
            case '.':
                state = STATE_END;
                break;
            case '\'':
                state = STATE_STRING;
                s += 1;
                break;
            default:
                if (i < MAXARGS) {
                    argv[i++] = ap;
                    state = STATE_NEXT;
                }
                else {
                    state = STATE_END;
                }
                break;
            }
            break;
        case STATE_NEXT:
            switch (*s) {
            case '=':
                *ap++ = *s;
                /* fall through */
            case ' ':
            case ',':
            case '(':
            case ':':
                *ap++ = '\0';
                state = STATE_START;
                break;
            case '\'':
                *ap++ = '\0';
                s -= 1;
                state = STATE_START;
                break;
            case ')':
            case '.':
                state = STATE_END;
                break;
            default:
                if (*s >= 'a' && *s <= 'z') {
                    *ap++ = *s - ('a' - 'A');
                }
                else {
                    *ap++ = *s;
                }
            }
            s += 1;
            break;
        case STATE_STRING:
            if (i < MAXARGS) {
                argv[i++] = ap;
                for (;;) {
                    if (s >= limit) {
                        state = STATE_END;
                        break;
                    }
                    else if (*s == '\'') {
                        s += 1;
                        if (s < limit && *s == '\'') {
                            *ap++ = '\'';
                            s += 1;
                        }
                        else {
                            *ap++ = '\0';
                            state = STATE_START;
                            break;
                        }
                    }
                    else if (*s == '\0') {
                        state = STATE_END;
                        break;
                    }
                    else {
                        *ap++ = *s++;
                    }
                }
            }
            else {
                state = STATE_END;
            }
            break;
        }
    }
    *ap = '\0';
    argv[i] = (char *)0;
    *argc = i;
}
