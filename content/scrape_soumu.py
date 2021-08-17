import csv
import random
import time
import requests
from bs4 import BeautifulSoup


# ひらがな部分をカタカナに変換する関数
def kata_to_hira(strj):
    return "".join([chr(ord(ch) + 96) if ("ぁ" <= ch <= "ゔ") else ch for ch in strj])


# 総務省のページをスクレイピング

C = []

for i in range(1, 12):
    if i < 10:
        num_str = "0" + str(i)
    else:
        num_str = str(i)
    r = requests.get(
        "https://www.soumu.go.jp/main_sosiki/joho_tsusin/security/glossary/"
        + num_str
        + ".html"
    )
    soup = BeautifulSoup(r.content, "lxml")
    A = soup.find_all("dt")
    B = soup.find_all("dd")
    size_A = len(A)
    for j in range(size_A):
        a = A[j]
        b = B[j]
        dt = a.get_text()  # 答え
        dd = b.get_text(strip=True)  # 問題文

        for k in range(len(dt)):  # ()部分がある場合、（）内にひらがな表記があるためそれを抽出
            if dt[k] == "（" or dt[k] == "(":
                break
        if k != len(dt) - 1:  # ()があったら
            kana = dt[k + 1 : -1]
            normal = dt[0:k]
            # dt = kana + "(" + normal + ")"
            dt = kana
        dt = kata_to_hira(dt)
        print(dt)

        s = -1
        for k in range(len(dd)):  # そのまま答えのため「〜の省略」の文は省く
            if dd[k] == "。":
                s = k
            if dd[k] == "略":
                break
        if k != len(dd) - 1:
            dd = dd[: s + 1] + dd[k + 2 :]
        dd0 = ""
        for k in range(len(dd)):  # 最初の１文だけ抽出
            if dd[k] == "。":
                dd0 = dd[0:k] + "。"
                break
        if len(dd0) < 20:
            dd0 = dd

        C.append([dt, dd0])
    time.sleep(5 + random.random())

with open("soumu.csv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(C)
