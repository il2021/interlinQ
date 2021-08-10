#!/usr/bin/env python
import MeCab
import fileinput
import regex as re
import jaconv
from warnings import warn

tagger = MeCab.Tagger("-Ochasen")
tagger.parse('')
re_quote = re.compile(r'[『』]', re.UNICODE)
re_last_ruby = re.compile(r'\(([\p{Hira}\p{Katakana}ー・]+)\)$', re.UNICODE)
re_ruby = re.compile(r'\([^\)]*\)', re.UNICODE)
re_not_wanted = re.compile(r'[^0-9A-Z\p{Katakana}ー]', re.UNICODE)

extra_dict = {
    '白樺派': 'シラカバハ',
    '荀子': 'ジュンシ',
    '靱猿': 'ウツボザル',
    '隕石': 'インセキ',
    '釆配': 'サイハイ',
    '薀蓄': 'ウンチク',
    '♯': 'シャープ',
    '!': 'エクスクラメーションマーク',
    '倖田來未': 'コウダクミ',
    '靫猿': 'ウツボザル',
    '鐚銭': 'ビタセン',
    '發': 'ハツ',
    '応永': 'オウエイ',
    '鞐': 'コハゼ',
    '姚明': 'ヤオミン',
    '☆(星)': 'ホシ',
}


def prep(txt):
    raw = txt.split('※', 1)[0]
    raw = re.sub(re_quote, '', raw)

    m = re_last_ruby.search(raw)
    if m:
        raw = m.group(1)

    return re.sub(re_ruby, '', raw)


def to_kana(txt):
    prepared = prep(txt)

    if prepared in extra_dict:
        return extra_dict[prepared]

    node = tagger.parseToNode(prepared)
    words = []
    while node:
        features = node.feature.split(',')
        if features[-2] != '*':
            words.append(features[-2])
        else:
            words.append(jaconv.hira2kata(node.surface))
        node = node.next

    kana = re.sub(re_not_wanted, '', ''.join(words).upper())

    if not kana:
        warn(txt)

    return kana


for line in fileinput.input():
    (question, answer) = line.strip().split("\t")
    print("\t".join((question, answer, to_kana(answer))))
