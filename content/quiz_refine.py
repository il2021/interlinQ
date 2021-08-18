# quiz.tsv の中で不適な問題を除外するコード

import csv

input_file = "quiz.tsv"
output_file = "quiz_refine.tsv"

ng_words = ["今年", "去年"]

with open(input_file, newline="") as input_f:
    with open(output_file, "w") as output_f:
        tsv = csv.writer(output_f, delimiter="\t", lineterminator="\n")

        for qid, problem, answer, answer_kana in csv.reader(input_f, delimiter="\t"):
            if answer == "":
                continue
            if any(word in problem for word in ng_words):
                continue

            print(qid, answer)

            tsv.writerow([qid, problem, answer, answer_kana])
