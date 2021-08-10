#!/usr/bin/env python
import MeCab
import fileinput
import regex as re
import jaconv

tagger = MeCab.Tagger("-Ochasen")
tagger.parse('')
re_last_ruby = re.compile(r'\(([\p{Hira}\p{Katakana}ー・]+)\)$', re.UNICODE)
re_ruby = re.compile(r'\([^\)]*\)', re.UNICODE)
re_not_wanted = re.compile(r'[^0-9A-Z\p{Katakana}ー]', re.UNICODE)


def prep(txt):
    raw = txt.split('※', 1)[0]

    m = re_last_ruby.search(raw)
    if m:
        raw = m.group(1)

    return re.sub(re_ruby, '', raw)


def to_kana(txt):
    prepared = prep(txt)

    node = tagger.parseToNode(prepared)
    words = []
    while node:
        features = node.feature.split(',')
        if features[-2] != '*':
            words.append(features[-2])
        else:
            words.append(jaconv.hira2kata(node.surface))
        node = node.next

    return re.sub(re_not_wanted, '', ''.join(words).upper())


for line in fileinput.input():
    (question, answer) = line.strip().split("\t")
    print("\t".join((question, answer, to_kana(answer))))
