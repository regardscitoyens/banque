#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv

OLD_ANON = {
  "@creditmutuel;2017-12-29": "Don de S.F.",
  "@creditmutuel;2019-01-02": "Don de S.F."
}
re_time = re.compile(r' [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$')

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
        if line[8] != u"Not available":
            line[9] = " ".join(line[7:9])
        for i, el in enumerate(line):
            line[i] = line[i].replace(u"Cliquer pour déplier ou plier le détail de l'opération ", "")
            line[i] = line[i].replace(u'Paiement récurrent de ', u'Don récurrent de ')
            line[i] = line[i].replace(u'Paiement de ', u'Don de ')
        if check in OLD_ANON:
            line[7] = OLD_ANON[check]
            line[9] = OLD_ANON[check]
        line[0] = re.sub(r'^[0-9A-Z]*@', '', line[0])
        line[2] = re_time.sub('', line[2])
        line[3] = re_time.sub('', line[3])
        if line[12] and line[12] not in ['commission', '0.00']:
            line[9] += (u' (€%.2f)' % (float(line[10]) - float(line[12]))).replace('.', ',')
        # Only keep lines with definitive date to avoid duplicates across multiple dates
        if len(line[2]) == 10:
            writer.writerow([el.encode('utf-8') for el in line])
      except Exception as e:
        print >> sys.stderr, "ERROR on line %s" % line
        raise e

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        process_data(csv.reader(f, delimiter=";"))
