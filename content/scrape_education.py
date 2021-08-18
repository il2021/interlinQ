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
import re
from collections import OrderedDict
from urllib import request

from bs4 import BeautifulSoup


class Scrape:
    def __init__(self):
        self._dict = OrderedDict()
        self.url = ""
        self.save_file_name = "quiz_education.csv"

    # backward compat
    @property
    def words(self):
        return list(self._dict.keys())

    # backward compat
    @property
    def meaning(self):
        return list(self._dict.values())

    def _init(self):
        with open(self.save_file_name, "w", encoding="utf-8") as f:
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
        re_hiragana = re.compile("[" + hiragana + "]", re.U)
        return bool(re_hiragana.search(string))

    def _save(self):
        with open(self.save_file_name, "a", encoding="utf-8") as f:
            writer = csv.writer(f)
            for word, meaning in self._dict.items():
                writer.writerow([meaning, word])

    def _get_contents_in_ministry_of_education(self):
        url1 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm"
        url2 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm"

        self.url = url1
        self._get_contents()
        contents_main = self.soup.find(id="contentsMain")
        for h4 in contents_main.find_all("h4"):
            sibling = h4.find_next_sibling("p")
            self._dict[h4.string] = sibling.string
        # print(self.words)
        # print(self.meaning)

        self.url = url2
        self._get_contents()
        contents_main = self.soup.find(id="contentsMain")
        for h2 in contents_main.find_all("h2", class_=None):
            word = str(h2.string)[1:-1]
            sibling = h2.find_next_sibling("p")
            meaning = sibling.get_text(strip=True)

            meaning_lst = meaning.split("。")
            if self._contain_japaneses(meaning_lst[0]):
                self._dict[word] = meaning
            else:
                # XXX: "。" will be disappeared
                self._dict[word] = "".join(meaning_lst[1:])

        self._save()
        # print(self.words)
        # print(self.meaning)

    def main(self):
        self._init()
        self._get_contents_in_ministry_of_education()


if __name__ == "__main__":
    Scrape().main()
