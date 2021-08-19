"""
* 文部科学省のサイト
  * https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm
  * https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm
* 片方はIT関連の単語ではないものもある。
* 何かの資料に含まれる単語の説明資料から引っ張ってきたので少し難しすぎるのかもしれないです。
* ライセンスは大丈夫だと思います。
  * https://www.mext.go.jp/b_menu/1351168.htm
* csvに生のデータを、tsvに手動含む整形データをいれました。
  * tsvファイルのうちeducation4, 12, 21, 31, 45, 49, 62, 63, 68, 70, 75, 96, 104, 105は手動で整形。
## TODO
* サイトによってファイルをわけていたのでわけているが、分けない方が良いですかね？
## 問題点
* 文にダブルクォーテーションが含まれるとうまく取得できないかも？
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
        self.save_file_name_csv = "quiz_education.csv"
        self.save_file_name_tsv = "quiz_education.tsv"
        self.num_of_question = 1
        self.soup = None

        self.exceptional_question = {
            4: "通信回線のデータ転送速度を表す単位を何というでしょう？",
            12: "広く普及しているネットワークシステムとして標準化されているLAN規格の一つを何というでしょう？",
            21: "社会的生産基盤のことであり、ダム・道路・港湾・発電所・通信施設などの産業基盤、および学校・病院・公園などの社会福祉・環境施設を表す略語を何というでしょう？",
            30: "インターネット等のネットワークを利用してデータのやり取りやサービスの授受を行う際、相手方が真にその名義人であるか、内容が改ざんされていないかを相互に保証するための仕組みのことを何というでしょう？",
            45: "高速な演算処理能力と大きな記憶容量をもち、画像処理のための高解像度ディスプレーやネットワーク接続機能等を備えているパソコンより高性能なコンピュータを何というでしょう？",
            49: "増加するインターネットの使用者に対応するため、現在のIP（IPv4）に代わるものとして準備が進められてきたプロトコルのことを何というでしょう？",
            62: "身に付けることが出来るという意味をもつ情報機器のことを何というでしょう？",
            63: "衛星の機能を維持するために必要な基本的機器で、構体、電源、テレメトリ・コマンド、熱制御、姿勢制御、推進などの各サブシステムに関する技術を何というでしょう？",
            68: "広い範囲に存在する複数のコンピュータをネットワークで接続し、強力な計算パワーを提供する仕組みを何というでしょう？",
            70: "環境や状況といったユーザを取り巻く情報をコンテクストとし、そのコンテクストに気づく（アウェアする）ことで、ユーザの目標としているタスクに最適な情報やサービスを提供する仕組みを何というでしょう？",
            75: "人間が活動する世界にコンピュータをとけこませるというアプローチで、計算機が計算機として人の前に現れるのではなく、人間の現実世界での活動の状況に応じてさりげなく支援を行うインターフェースのことを何というでしょう？",
            96: "インターネットを介して提供されている様々なサービス・情報源への入り口を集めたWebページを実現するシステムのことを何というでしょう？",
            104: "いつでもどこでも情報にアクセスできるような環境のことを何というでしょう？",
            105: "電子をそこに閉じ込めることにより、その性質を完全に制御することができる10ナノメートル程度の箱を何というでしょう？",
        }

    # backward compat
    @property
    def words(self):
        return list(self._dict.keys())

    # backward compat
    @property
    def meaning(self):
        return list(self._dict.values())

    def _init(self):
        self._init_save_file(self.save_file_name_csv)
        self._init_save_file(self.save_file_name_tsv)

    def _init_save_file(self, file_name):
        with open(file_name, "w", encoding="utf-8", newline="\n") as f:
            writer = csv.writer(f, lineterminator="\n")
            writer.writerow(["**文部科学省のサイトより**"])

    def _get_contents(self):
        with request.urlopen(self.url) as resp:
            self.soup = BeautifulSoup(resp, features="html.parser")

    def _contain_japaneses(self, string):
        hiragana = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
        re_hiragana = re.compile("[" + hiragana + "]", re.U)
        return bool(re_hiragana.search(string))

    def _save(self):
        csv_file = self.save_file_name_csv
        tsv_file = self.save_file_name_tsv
        with open(csv_file, "a") as f_csv, open(tsv_file, "a") as f_tsv:
            writer_csv = csv.writer(f_csv, lineterminator="\n")
            writer_tsv = csv.writer(f_tsv, delimiter="\t", lineterminator="\n")
            tmp = "education"

            for word, meaning in self._dict.items():
                writer_csv.writerow([meaning, word])

                id = tmp + str(self.num_of_question)
                question = meaning.split("。")[0] + "を何というでしょう？"
                if self.num_of_question in self.exceptional_question:
                    question = self.exceptional_question[self.num_of_question]
                writer_tsv.writerow([id, question, word])

                self.num_of_question += 1

    def _get_contents_in_ministry_of_education(self):
        url1 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu4/toushin/attach/1337927.htm"
        url2 = "https://www.mext.go.jp/b_menu/shingi/gijyutu/gijyutu2/suishin/attach/1332892.htm"

        self.url = url1
        self._get_contents()
        contents_main = self.soup.find(id="contentsMain")
        for h4 in contents_main.find_all("h4"):
            sibling = h4.find_next_sibling("p")
            self._dict[h4.string] = sibling.get_text(strip=True)
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
