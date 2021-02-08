#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv

re_not = re.compile(r'Not (available|loaded)')
#Paypal Anonymisation
re_ano = re.compile(ur'(Don( récurrent)? de )(\w)[^\s\.]+( +(\w)[^\s\.].*)?$', re.I)
sub_ano = lambda x: x.group(1) + (x.group(3) + "." + (x.group(5) or "") + ".").upper()
ano = lambda x: re_ano.sub(sub_ano, x)
#Virement Anonymisation VIR M. XXXX YYYY => VIR M. X.Y.
re_ano2 = re.compile(ur'M\. ([A-Z])[A-Z]+ ([A-Z])[A-Z]+ ([0-9\- ]+)( .*|$)')
sub_ano2 = lambda x: "M. "+x.group(1)+"."+x.group(2)+". "+x.group(3)
ano2 = lambda x: re_ano2.sub(sub_ano2, x)

re_creditmut = re.compile(r'(SEPA ONLINE SAS) ONL (\d+)( DEDIBOX \2)')
def process_data(data):
    writer = csv.writer(sys.stdout, lineterminator='\n')
    for line in data:
      try:
        if not line:
            continue
        if line[0] == 'id':
            writer.writerow(line)
            continue
        for i, el in enumerate(line):
            line[i] = re_not.sub('', line[i].decode('utf-8'))
            line[i] = ano(line[i])
            line[i] = ano2(line[i])
            line[i] = re_creditmut.sub(r'\1\3', line[i])
        writer.writerow([el.encode('utf-8') for el in line])
      except Exception as e:
        print >> sys.stderr, "ERROR on line %s" % line
        raise e

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        process_data(csv.reader(f, delimiter=","))
