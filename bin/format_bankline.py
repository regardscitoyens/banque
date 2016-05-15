#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re

if __name__ == "__main__":
  for line in sys.stdin:
    if line.startswith('id;url'):
        sys.stdout.write(line)
        continue
    line = line.decode('utf-8')
    line = re.sub(r'^"[0-9A-Z]*@', '"', line)
    line = re.sub(r' [0-2][0-9]:[0-5][0-9]:[0-5][0-9]";', '";', line)
    line = re.sub(r'Not (available|loaded)', '', line)
    line = line.replace(u'Paiement récurrent de ', u'Don récurrent de ')
    line = re.sub(ur'(Don( récurrent)? de )(\w)[^; ]+( (\w)[^; ]+)*?";', r'\1\3.\5.";', line, re.I)
    data = line.split('";"')
    if data[11] and data[11] not in ['commission', '0.00']:
        data[8] += (u' (€%.2f)' % (float(data[9]) - float(data[11]))).replace('.', ',')
        line = '";"'.join(data)
    # Only keep lines with definitive date to avoid duplicates across multiple dates
    if data[2] == "date" or len(data[2]) == 10 or data[2].endswith(' 00:00:00'):
        sys.stdout.write(line.encode('utf-8'))

