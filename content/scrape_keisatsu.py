import csv
import re

import requests
from bs4 import BeautifulSoup


# ひらがな部分をカタカナに変換する関数
def kata_to_hira(strj):
    return "".join([chr(ord(ch) + 96) if ("ぁ" <= ch <= "ゔ") else ch for ch in strj])


# 警察庁のページをスクレイピング

container = []

resp = requests.get("https://www.npa.go.jp/cyberpolice/words/index.html")
soup = BeautifulSoup(resp.content, "lxml")

for li in soup.find_all("li"):
    anchor = li.find_all("a", id=lambda value: value and value.startswith(""))
    paragraph = li.find_all("p")
    if len(anchor) > 0 and len(paragraph) > 0:
        answer = anchor[0].get_text()
        question = paragraph[0].get_text()

        match_brace = re.match(
            r"""
               ^
                   ([^（(]*)  # normal
                   [（(]      # opening brace
                   (.*)       # kana
                   .          # closing brace
               $
            """,
            answer,
            re.X | re.M | re.S,
        )

        if match_brace:
            normal = match_brace.group(1)
            kana = match_brace.group(2)
            answer = kana + "(" + normal + ")"
            print(answer)

        if '略' in question:
            question = question[question.index('略') + 2:]  # 2 for "。"

        container.append([answer, question])

with open("keisatsu.csv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(container)
