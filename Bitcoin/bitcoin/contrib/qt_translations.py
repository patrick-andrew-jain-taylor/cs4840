#!/usr/bin/env python

# Helpful little script that spits out a comma-separated list of
# language codes for Qt icons that should be included
# in binary bitcoin distributions

import glob
import os
import re
import sys

if len(sys.argv) != 3:
  sys.exit(f"Usage: {sys.argv[0]} $QTDIR/translations $BITCOINDIR/src/qt/locale")

d1 = sys.argv[1]
d2 = sys.argv[2]

l1 = {
    re.search(r'qt_(.*).qm', f)[1]
    for f in glob.glob(os.path.join(d1, 'qt_*.qm'))
}
l2 = {
    re.search(r'bitcoin_(.*).qm', f)[1]
    for f in glob.glob(os.path.join(d2, 'bitcoin_*.qm'))
}

import glob
print ",".join(sorted(l1.intersection(l2)))

