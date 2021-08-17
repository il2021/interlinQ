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

from urllib import request
import time
import random
import unicodedata
from bs4 import BeautifulSoup
import csv


class Scrape:
    def __init__(self):
        self.words = []
        self.meaning = []
        self.url = ''
        self.saveFileName = 'quiz_education.csv'

    def _init(self):
        with open (self.saveFileName, 'w', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['**文部科学省のサイトより**'])

    def _getContents(self):
        self.res = request.urlopen(self.url)
        self.soup = BeautifulSoup(self.res, features='html.parser')
        self.res.close()
        time.sleep(5.0 + random.random())

    '''
    * 日本語が含まれるかどうか判定
    * https://minus9d.hatenablog.com/entry/2015/07/16/231608
    * ひらがながふくまれていなければ全部英字（正式名称）であると仮定。
    '''
    def _containJapaneses(self, string):
        hiragana = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん'
        for ch in string:
            if ch in hiragana:
                return True
        return False

    def _changeEnc(self, string, enc='utf-8'):
        return string.encode(enc).decode(enc)

    def _save(self):
        with open (self.saveFileName, 'a', encoding='utf-8') as f:
            writer = csv.writer(f)
            for i in range(len(self.words)):
                writer.writerow([self.meaning[i], self.words[i]])

    def _getContentsInMinistryOfEducation(self):
        url1 = 'https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm'
        url2 = 'https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm'

        self.url = url1
        self._getContents()
        self.words = [self._changeEnc(str(word.string)) for word in self.soup.find(id='contentsMain').find_all('h4')]
        self.meaning = [self._changeEnc(str(meaning.string)) for meaning in self.soup.find(id='contentsMain').find_all('p')]
        self._save()
        #print(self.words)
        #print(self.meaning)

        self.url = url2
        self._getContents()
        self.words = [self._changeEnc(str(word.string))[1:-1] for word in self.soup.find(id='contentsMain').find_all('h2')][:-1]
        self.meaning = [self._changeEnc(str(meaning.string))[1:] for meaning in self.soup.find(id='contentsMain').find_all('p')][:-1]
        for i in range(len(self.meaning)):
            if not self._containJapaneses(str(self.meaning[i]).split('。')[0]):
                tmp = str(self.meaning[i]).split('。')
                self.meaning[i] = ''
                for j in range(1, len(tmp)):
                    self.meaning[i] += tmp[j]
        self._save()
        #print(self.words)
        #print(self.meaning)

    def main(self):
        self._init()
        self._getContentsInMinistryOfEducation()


if __name__ == '__main__':
    Scrape().main()
