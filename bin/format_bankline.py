#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv

re_not = re.compile(r'Not (available|loaded)')
re_time = re.compile(r' [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$')
re_ano = re.compile(ur'(Don( récurrent)? de )(\w)\S+( (\w).*)?$', re.I)
def process_data(data):
    writer = csv.writer(sys.stdout)
    for line in data:
        if not line:
            continue
        if line[0] == 'id':
            writer.writerow(line)
            continue
        for i, el in enumerate(line):
            line[i] = re_not.sub('', line[i].decode('utf-8'))
            line[i] = line[i].replace(u'Paiement récurrent de ', u'Don récurrent de ')
            line[i] = re_ano.sub(r'\1\3.\5.', line[i])
        line[0] = re.sub(r'^[0-9A-Z]*@', '', line[0])
        line[2] = re_time.sub('', line[2])
        line[3] = re_time.sub('', line[3])
        if line[11] and line[11] not in ['commission', '0.00']:
            line[8] += (u' (€%.2f)' % (float(line[9]) - float(line[11]))).replace('.', ',')
        # Only keep lines with definitive date to avoid duplicates across multiple dates
        if len(line[2]) == 10:
            writer.writerow([el.encode('utf-8') for el in line])

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        process_data(csv.reader(f))
