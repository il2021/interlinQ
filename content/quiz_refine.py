# quiz.tsv の中で不適な問題を除外するコード

import csv

input_file = "quiz.tsv"
output_file = "quiz_refine.tsv"

NG_Words = ["今年", "去年"]

with open(input_file, newline="") as input_f:
    with open(output_file, "w", encoding="utf_8_sig") as output_f:
        tsv = csv.writer(output_f, delimiter="\t", lineterminator="\r\n")

        for id, problem, answer, answer_kana in csv.reader(input_f, delimiter="\t"):
            if answer == "":
                continue
            if any(word in problem for word in NG_Words):
                continue

            print(id, answer)

            tsv.writerow([id, problem, answer, answer_kana])
