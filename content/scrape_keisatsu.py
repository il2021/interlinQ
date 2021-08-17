import csv
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

        for pos in range(len(answer)):
            if answer[pos] == "（" or answer[pos] == "(":
                break
        if pos != len(answer) - 1:
            kana = answer[pos + 1:-1]
            normal = answer[0:pos]
            answer = kana + "(" + normal + ")"
            print(answer)

        for i in range(len(question)):
            if question[i] == "略":
                break
        if i != len(question) - 1:
            question = question[i + 2:]

        container.append([answer, question])

with open("keisatsu.csv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(container)
