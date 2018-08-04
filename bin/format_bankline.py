#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv

ANON = {
  "@creditmutuel;2017-12-29": "Don de S.F."
}

re_not = re.compile(r'Not (available|loaded)')
re_time = re.compile(r' [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$')
re_ano = re.compile(ur'(Don( récurrent)? de )(\w)\S+( +(\w).*)?$', re.I)
sub_ano = lambda x: x.group(1) + (x.group(3) + "." + (x.group(5) or "") + ".").upper()
ano = lambda x: re_ano.sub(sub_ano, x)
re_creditmut = re.compile(r'(SEPA ONLINE SAS) ONL (\d+)( DEDIBOX \2)')
def process_data(data):
    writer = csv.writer(sys.stdout)
    for line in data:
      try:
        if not line:
            continue
        if line[0] == 'id':
            writer.writerow(line)
            continue
        check = "%s;%s" % (line[0], line[2])
        if line[7] != u"Not available":
            line[8] = " ".join(line[7:9])
        for i, el in enumerate(line):
            line[i] = re_not.sub('', line[i].decode('utf-8'))
            line[i] = line[i].replace(u"Cliquer pour déplier ou plier le détail de l'opération ", "")
            line[i] = line[i].replace(u'Paiement récurrent de ', u'Don récurrent de ')
            line[i] = line[i].replace(u'Paiement de ', u'Don de ')
            line[i] = ano(line[i])
            line[i] = re_creditmut.sub(r'\1\3', line[i])
        if check in ANON:
            line[6] = ANON[check]
            line[8] = ANON[check]
        line[0] = re.sub(r'^[0-9A-Z]*@', '', line[0])
        line[2] = re_time.sub('', line[2])
        line[3] = re_time.sub('', line[3])
        if line[11] and line[11] not in ['commission', '0.00']:
            line[8] += (u' (€%.2f)' % (float(line[9]) - float(line[11]))).replace('.', ',')
        # Only keep lines with definitive date to avoid duplicates across multiple dates
        if len(line[2]) == 10:
            writer.writerow([el.encode('utf-8') for el in line])
      except Exception as e:
        print >> sys.stderr, "ERROR on line %s" % line
        raise e

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        process_data(csv.reader(f, delimiter=";"))
