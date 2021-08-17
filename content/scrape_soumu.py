import csv
import random
import time
import requests
from bs4 import BeautifulSoup


# ひらがな部分をカタカナに変換する関数
def kata_to_hira(strj):
    return "".join([chr(ord(ch) + 96) if ("ぁ" <= ch <= "ゔ") else ch for ch in strj])


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

        # Find the first opening brace and store its position as pos
        for pos in range(len(dt)):  # ()部分がある場合、（）内にひらがな表記があるためそれを抽出
            if dt[pos] == "（" or dt[pos] == "(":
                break

        if pos != len(dt) - 1:  # ()があったら
            kana = dt[pos + 1:-1]
            normal = dt[0:pos]
            # dt = kana + "(" + normal + ")"
            dt = kana
        dt = kata_to_hira(dt)
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

<<<<<<< HEAD
with open('soumu.csv', 'w', encoding="utf_8_sig", newline = '') as f:
   writer = csv.writer(f)
   writer.writerows(C)
=======
        container.append([dt, dd0])
    time.sleep(5 + random.random())
>>>>>>> caca85537136400c77722dad76eb92a93fa64ebd

with open("soumu.csv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(container)
