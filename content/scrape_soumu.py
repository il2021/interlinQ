import csv
import random
import re
import time

import jaconv
import requests
from bs4 import BeautifulSoup


# 総務省のページをスクレイピング

container = []

for i in range(1, 12):
    if i < 10:
        num_str = "0" + str(i)
    else:
        num_str = str(i)
    resp = requests.get(
        "https://www.soumu.go.jp/main_sosiki/joho_tsusin/security/glossary/"
        + num_str
        + ".html"
    )
    soup = BeautifulSoup(resp.content, "lxml")
    dom_dt = soup.find_all("dt")
    dom_dd = soup.find_all("dd")
    size_A = len(dom_dt)
    for j in range(size_A):
        dt = dom_dt[j].get_text()  # 答え
        dd = dom_dd[j].get_text(strip=True)  # 問題文

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

        start_pos = -1
        for pos in range(len(dd)):  # そのまま答えのため「〜の省略」の文は省く
            if dd[pos] == "。":
                start_pos = pos
            if dd[pos] == "略":
                break

        if pos != len(dd) - 1:
            dd = dd[: start_pos + 1] + dd[pos + 2:]

        dd0 = ""
        for pos in range(len(dd)):  # 最初の１文だけ抽出
            if dd[pos] == "。":
                dd0 = dd[0:pos] + "。"
                break
        if len(dd0) < 20:
            dd0 = dd

        container.append([dt, dd0])
    time.sleep(5 + random.random())

with open("soumu.csv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(container)
