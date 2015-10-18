#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv

if __name__ == "__main__":
  for line in sys.stdin:
    line = line.decode('utf-8')
    line = re.sub(r'^[0-9A-Z]*@', '', line)
    line = re.sub(r' [0-2][0-9]:[0-5][0-9]:[0-5][0-9];', ';', line)
    line = re.sub(r'Not (available|loaded)', '', line)
    line = line.replace(u'Paiement récurrent de ', u'Don récurrent de ')
    line = re.sub(ur'(Don( récurrent)? de )(\w)[^; ]+( (\w)[^; ]+)*?;', r'\1\3.\5.;', line, re.I)
    data = line.split(';')
    if data[10] and data[10] not in ['commission', '0.00']:
        data[7] += (u' (€%.2f)' % (float(data[8]) - float(data[10]))).replace('.', ',')
        line = ';'.join(data)
    sys.stdout.write(line.encode('utf-8'))

