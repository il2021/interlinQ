#!/usr/bin/env python
import MeCab
import fileinput
import regex as re
import jaconv
from warnings import warn

tagger = MeCab.Tagger("-Ochasen")
tagger.parse('')
re_space = re.compile(r'\s', re.UNICODE)
re_quote = re.compile(r'[『』]', re.UNICODE)
re_digraph = re.compile(r'[【\[][^】\]]+[】\]]', re.UNICODE)
re_last_ruby = re.compile(r'\(([\p{Hira}\p{Katakana}ー][\p{Hira}\p{Katakana}ー・]*)\)$', re.UNICODE)
re_ruby = re.compile(r'\([^\)]*\)', re.UNICODE)
re_following_num = re.compile(r'^(-?[0-9.]+)(?!分の)', re.UNICODE)
re_date = re.compile(r'([0-9]+)年([0-9]+)月([0-9]+)日', re.UNICODE)
re_unwanted = re.compile(r'[^0-9A-Z\p{Katakana}ー.]', re.UNICODE)

question_dict = {
    '大相撲で、平幕の力士が横綱を倒したときの勝星を何というでしょう？': 'キンボシ',
    '動物、スポーツ、映画、音楽、料理など、いろいろな「好き」を入口に514種の職業を紹介した、村上龍による仕事の百科全書といえば何でしょう？': '１３サイノハローワーク',
    'スキューバダイビングをするために必要となる認定証のことを、アルファベット1文字で何カードというでしょう？': 'Ｃ',
    '生後6か月頃から満1歳前後の乳児にみられる発熱を、とくに何というでしょう？': 'チエネツ',
    '数の単位で、1万を1万倍すると1億になりますが、1億を1億倍するといくつになるでしょう？': '１ケイ',
    '江戸後期、破綻した藩の財政を立て直すため、養蚕(ようさん)や荒地の開墾を奨励した米沢藩主は誰でしょう？': 'ウエスギヨウザン',
    'NASAが開発した、危険度分析による食品衛生管理システムのことを、アルファベット5文字で何というでしょう？': 'ＨＡＣＣＰ',
}

answer_dict = {
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
    '満を持す': 'マンヲジス',
    '和井内貞行': 'ワイナイサダユキ',
    '浅井長政': 'アザイナガマサ',
    '阪東妻三郎': 'バンドウツマサブロウ',
    '山名持豊': 'ヤマナモチトヨ',
    '景徳鎮': 'ケイトクチン',
    '空腸': 'クウチョウ',
}


def prep(txt):
    raw = txt.split('※', 1)[0]
    raw = re.sub(re_space, '', raw)
    raw = re.sub(re_digraph, '', raw)
    raw = re.sub(re_quote, '', raw)

    m = re_last_ruby.search(raw)
    if m:
        raw = m.group(1)

    return re.sub(re_ruby, '', raw)


def run_mecab(txt):
    node = tagger.parseToNode(txt)
    words = []
    while node:
        features = node.feature.split(',')
        if features[-2] != '*':
            words.append(features[-2])
        else:
            words.append(node.surface)
        node = node.next
    return ''.join(words)


def to_kana(question, answer):
    if question in question_dict:
        return question_dict[question]

    prepared = prep(answer)

    if prepared in answer_dict:
        return answer_dict[prepared]

    m = re_date.match(prepared)
    if m:
        prepared = '%sネン%sガツ%sニチ' % m.group(1, 2, 3)
    else:
        m = re_following_num.search(prepared)
        if m:
            prepared = m.group(1)

    kana = run_mecab(prepared)
    kana = jaconv.hira2kata(kana)
    kana = kana.upper()
    kana = re.sub(re_unwanted, '', kana)
    kana = jaconv.h2z(kana, ascii=True, digit=True)

    if not kana:
        warn(question)

    return kana


for line in fileinput.input():
    (question, answer) = line.strip().split("\t")
    print("\t".join((question, answer, to_kana(question, answer))))
