# content

クイズに必要なデータを収集/整理するスクリプト

# INSTALL

## MeCabのインストール

    $ brew install mecab mecab-ipadic

## mecab-ipadic-neologdのインストール

    $ git clone --depth 1 "https://github.com/neologd/mecab-ipadic-neologd.git"
    $ ( cd mecab-ipadic-neologd; ./bin/install-mecab-ipadic-neologd -n -y; )

## Pythonのパッケージをインストールする仮想環境を用意

    $ python -m venv local
    $ . local/bin/activate

## 必要なPythonパッケージのインストール

    $ pip install -r requirements.txt

# RUN

    $ ./scrape.py | ./ruby.py > quiz.tsv
