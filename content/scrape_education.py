"""
* 文部科学省のサイト
  * https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm
  * https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm
* 片方はIT関連の単語ではないものもある。そして少し難しすぎるのかもしれないです。
* ライセンスは大丈夫だと思います。
  * https://www.mext.go.jp/b_menu/1351168.htm
## TODO
* サイトによってファイルをわけていたのでわけているが、分けない方が良いですかね？
## 問題点
* 文にダブルクォーテーションが含まれるとうまく取得できないっぽいです。
  * 「認証基盤」：インターネット等のネットワークを利用してデータのやり取りやサービスの授受を行う際、相手方が真にその名義人であるか、内容が改ざんされていないかを相互に保証するための仕組み
  * これは手動でやる必要があるかもしれません。
"""

import csv
from urllib import request

from bs4 import BeautifulSoup


class Scrape:
    def __init__(self):
        self.words = []
        self.meaning = []
        self.url = ""
        self.saveFileName = "quiz_education.csv"

    def _init(self):
        with open(self.saveFileName, "w", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["**文部科学省のサイトより**"])

    def _get_contents(self):
        with request.urlopen(self.url) as resp:
            self.soup = BeautifulSoup(resp, features="html.parser")

    """
    * 日本語が含まれるかどうか判定
    * https://minus9d.hatenablog.com/entry/2015/07/16/231608
    * ひらがながふくまれていなければ全部英字（正式名称）であると仮定。
    """

    def _contain_japaneses(self, string):
        hiragana = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
        for ch in string:
            if ch in hiragana:
                return True
        return False

    def _change_enc(self, string, enc="utf-8"):
        return string.encode(enc).decode(enc)

    def _save(self):
        with open(self.saveFileName, "a", encoding="utf-8") as f:
            writer = csv.writer(f)
            for i in range(len(self.words)):
                writer.writerow([self.meaning[i], self.words[i]])

    def _get_contents_in_ministry_of_education(self):
        url1 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm"
        url2 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm"

        self.url = url1
        self._get_contents()
        self.words = [
            self._change_enc(str(word.string))
            for word in self.soup.find(id="contentsMain").find_all("h4")
        ]
        self.meaning = [
            self._change_enc(str(meaning.string))
            for meaning in self.soup.find(id="contentsMain").find_all("p")
        ]
        self._save()
        # print(self.words)
        # print(self.meaning)

        self.url = url2
        self._get_contents()
        self.words = [
            self._change_enc(str(word.string))[1:-1]
            for word in self.soup.find(id="contentsMain").find_all("h2")
        ][:-1]
        self.meaning = [
            self._change_enc(str(meaning.string))[1:]
            for meaning in self.soup.find(id="contentsMain").find_all("p")
        ][:-1]
        for i in range(len(self.meaning)):
            if not self._contain_japaneses(str(self.meaning[i]).split("。")[0]):
                tmp = str(self.meaning[i]).split("。")
                self.meaning[i] = ""
                for j in range(1, len(tmp)):
                    self.meaning[i] += tmp[j]
        self._save()
        # print(self.words)
        # print(self.meaning)

    def main(self):
        self._init()
        self._get_contents_in_ministry_of_education()


if __name__ == "__main__":
    Scrape().main()
