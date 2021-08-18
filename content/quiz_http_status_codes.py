# http-status-codes-1.csv を用いてHTTPステータスコードを問う問題を作成する

import csv

Data_input = []

with open("http-status-codes-1.csv", encoding="utf-8", newline="") as f:
    for cols in csv.reader(f):
        Data_input.append(cols)

ID = []
Problems = []
Answers = []
Answers_kana = []


for i, sentence in enumerate(Data_input):
    if sentence[1] == "Unassigned" or sentence[1] == "Description":
        continue

    id = "http-status-codes" + str(i)
    problem = "「" + sentence[1] + "」" + "を表すHTTPのステータスコードは何か"
    answer = sentence[0]
    answer_kana = sentence[0]

    ID.append(id)
    Problems.append(problem)
    Answers.append(answer)
    Answers_kana.append(answer_kana)
    print(problem, answer)


Data_output = []

for i in range(len(Answers)):
    id = ID[i]
    problem = Problems[i]
    answer = Answers[i]
    answer_kana = Answers_kana[i]
    string = id + "\t" + problem + "\t" + answer + "\t" + answer_kana
    Data_output.append([string])

with open("quiz_http_status_codes.tsv", "w", encoding="utf_8", newline="\n") as f:
    writer = csv.writer(f, lineterminator="\n")
    writer.writerows(Data_output)
