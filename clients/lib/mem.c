/* For gcc, compile with -fno-builtin to suppress warnings */

#include "1275.h"

VOID
memcpy(char *to, char *from, int len)
{
	while (len--)
		*to++ = *from++;
}

VOID
memset(char *cp, int c, int len)
{
	while (len--)
		*(cp + len) = c;
}
