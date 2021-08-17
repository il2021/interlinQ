#!/usr/bin/env python
import requests
from lxml import html

BASE_URL = "http://qss.quiz-island.site/abcgo/"
BASE_ID = "abcgo"

for target in range(2003, 2014 + 1):
    page = 1
    total = None
    index = 0

    while True:
        response = requests.get(BASE_URL, params={
            'formname': 'lite_search',
            'target': target,
            'page': page,
        })

        dom = html.fromstring(response.text)

        for tr in dom.cssselect("#quizzes_list tr"):
            index += 1
            qid = "%s%s-%05d" % ((BASE_ID, target, index))
            question = tr.cssselect("td:nth-child(3) a")[0].text_content()
            answer = tr.cssselect("td:nth-child(3) > div:nth-child(4)")[
                0
            ].text_content()
            answer = answer.removeprefix("正解 : ")
            print("\t".join((qid, question, answer)))

        if total is None:
            sel = '.pb-5 > p:nth-child(1) > strong:nth-child(1)'
            total = int(dom.cssselect(sel)[0].text_content())

        page += 1

        if page * 100 > total:
            break
