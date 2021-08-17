# requestsというライブラリを読み込む
# HTTPへのアクセスを簡易に提供するライブラリ
import requests
import re

import time
import random

import csv

from bs4 import BeautifulSoup

# ひらがな部分をカタカナに変換する関数
def kata_to_hira(strj):
    return "".join([chr(ord(ch) + 96) if ("ぁ" <= ch <= "ゔ") else ch for ch in strj])

# 警察庁のページをスクレイピング

C=[]

r=requests.get("https://www.npa.go.jp/cyberpolice/words/index.html")
soup = BeautifulSoup(r.content,'lxml')
S = soup.find_all("li")

for T in S:
  A = T.find_all("a", id=lambda value: value and value.startswith(""))
  B = T.find_all("p")
  if len(A)>0 and len(B)>0:
    a = A[0].get_text() #答え
    b = B[0].get_text() #問題文

    for k in range(len(a)):
      if a[k]=="（" or a[k]=="(":
        break
    if k!=len(a)-1:
      kana = a[k+1:-1] 
      normal = a[0:k]
      a = kana + "(" + normal + ")"
      print(a)

    for i in range(len(b)):
      if b[i]=="略":
        break
    if i!=len(b)-1:
      b = b[i+2:]
      
    C.append([a,b])

with open('keisatsu.csv', 'w', encoding="utf_8_sig", newline = '') as f:
   writer = csv.writer(f) 
   writer.writerows(C)
