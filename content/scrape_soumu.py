import csv
import re

import jaconv
import requests
from bs4 import BeautifulSoup


# 総務省のページをスクレイピング

container = []

for i in range(1, 12):
    resp = requests.get(
        f"https://www.soumu.go.jp/main_sosiki/joho_tsusin/security/glossary/{i:02d}.html"
    )
    soup = BeautifulSoup(resp.content, "lxml")
    for dom_dt in soup.find_all("dt"):
        dom_dd = dom_dt.find_next_sibling("dd")
        dt = dom_dt.get_text()  # 答え
        dd = dom_dd.get_text(strip=True)  # 問題文

        match_brace = re.match(
            r"""
               ^
                   ([^（(]*)  # normal
                   [（(]      # opening brace
                   (.*)       # kana
                   .          # XXX: closing brace
               $
            """,
            dt,
            re.X | re.M | re.S,
        )

        if match_brace:
            normal = match_brace.group(1)
            kana = match_brace.group(2)
            # dt = kana + "(" + normal + ")"
            dt = kana

        dt = jaconv.hira2kata(dt)
        print(dt)

        dd_sentences = re.split(r"(?<=。)(?!$)", dd, re.U)

        # そのまま答えのため「〜の省略」の文は省く
        dd_sentences = [x for x in dd_sentences if not x.endswith("略。")]
        dd0 = dd_sentences[0]  # 最初の１文だけ抽出
        if len(dd0) < 20:
            dd0 = "".join(dd_sentences)

        container.append([dt, dd0])

with open("soumu.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(container)
