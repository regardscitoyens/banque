#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, re, csv, codecs
from format_bankline import ano

re_date = re.compile(r"(..)/(..)/(....)")
datize = lambda d: re_date.sub(r"\3-\2-\1", d)
fixcommas = lambda x: x.replace(",", ".")
csvformat = lambda x: '"%s"' % x.replace('"', '""') if "," in x else x

def process(data):
    for row in reversed(data):
        if not row["État de l'adresse"]:
            continue

        if row["Type"] == "Paiement d'abonnement":
            raw = "Don récurrent de "
        elif row["Type"] == "Paiement de don":
            raw = "Don de "
        elif row["Type"] in [
          "Paiement préapprouvé d'un utilisateur de facture de paiement",
          "Paiement sur site marchand"
        ]:
            raw = "Paiement à "
        elif row["Type"] in ["Paiement par PayPal Option+"]:
            raw = "Achat effectué auprès de "
        else:
            print >> sys.stderr, "ERROR: unknown type of line", row["Type"]
            print >> sys.stderr, row
            continue
        raw += row["Nom"]
        if raw.startswith("Don"):
            raw = ano(raw.decode("utf-8")).encode("utf-8")
        label = raw
        if row["Commission"] != "0,00":
            label += (" (€%.2f)" % float(fixcommas(row["Avant commission"]))).replace(".", ",")

        print ",".join([
            datize(row['\xef\xbb\xbf"Date"']),
            "paypal",
            fixcommas(row["Net"]),
            csvformat(raw),
            "0",
            fixcommas(row["Commission"]),
            "",
            csvformat(label)
        ])

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        process(list(csv.DictReader(f)))
