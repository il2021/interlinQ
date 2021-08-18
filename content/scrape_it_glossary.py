"""
* IT用語辞典(https://e-words.jp/)の単語と説明をいいかんじにスクレイピングするコード
* ライセンス的にダメっぽい

## TODO
* まだファイルに保存するコードは書いていない
"""

import random
import time
from urllib import request

from bs4 import BeautifulSoup


class Scrape:
    def __init__(self):
        self.words = []
        self.meaning = []
        self.domain = ""
        self.url = ""

    def _getContents(self):
        self.res = request.urlopen(self.url)
        self.soup = BeautifulSoup(self.res)
        self.res.close()
        time.sleep(5.0 + random.random())

    def _getContentsInITGlossary(self):
        self.domain = "https://e-words.jp/"

        self.vowel = ["a", "i", "u", "e", "o"]
        self.consonant = ["a", "k", "s", "t", "n", "h", "m", "y", "r", "w"]

        for c in self.consonant:
            for v in self.vowel:
                if (c == "y" and (v == "i" or v == "e")) or (c == "w" and v != "a"):
                    continue

                self.url = self.domain + "p/i-k" + c + v + ".html"

                self._getContents()

                self.wordUrlList = [
                    url.a.get("href")
                    for url in self.soup.find(id="index-list").find_all("li")
                ]
                self.wordUrlList = [
                    self.domain + url[3:] for url in self.wordUrlList
                ]  # 各50音に含まれる単語のurl
                # print(wordUrlList)

                for self.url in self.wordUrlList:
                    self._getContents()
                    content = self.soup.find(id="Summary")

                    if content is None:
                        continue

                    word = content.strong.string
                    self.words.append(word)
                    meaning = str(content).split("とは、")[1].split("。")[0]
                    self.meaning.append(meaning)

                    print(word + " : " + meaning)

    def main(self):
        self._getContentsInITGlossary()


if __name__ == "__main__":
    Scrape().main()
