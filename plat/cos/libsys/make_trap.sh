#!/bin/sh
cat <<EOF
#include "trap.h"
text:    section code
         entry   @$1
@$1:
         s1      $2
         j       %%trp
         end
EOF
