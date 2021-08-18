# quiz.tsv の中で不適な問題を除外するコード

import csv

Data_input = []

with open("quiz.tsv", encoding="utf-8", newline="") as f:
    for row in csv.reader(f, delimiter="\t"):
        Data_input.append(row)

ID = []
Problems = []
Answers = []
Answers_kana = []

NG_Words = ["今年", "去年"]

for id, problem, answer, answer_kana in Data_input:
    if answer == "":
        continue
    if any(word in problem for word in NG_Words):
        continue
    ID.append(id)
    Problems.append(problem)
    Answers.append(answer)
    Answers_kana.append(answer_kana)
    print(id, answer)


Data_output = []

for i in range(len(Answers)):
    id = ID[i]
    problem = Problems[i]
    answer = Answers[i]
    answer_kana = Answers_kana[i]
    string = id + "\t" + problem + "\t" + answer + "\t" + answer_kana
    Data_output.append([string])

with open("quiz_refine.tsv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(Data_output)
