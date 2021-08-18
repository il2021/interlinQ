# http-status-codes-1.csv を用いてHTTPステータスコードを問う問題を作成する

import csv

Data_input = []
input_file = "http-status-codes-1.csv"
output_file = "quiz_http_status_codes.tsv"

with open(input_file, newline="\r\n") as input_f:
    with open(output_file, "w", newline="") as output_f:
        tsv = csv.writer(output_f, delimiter="\t", lineterminator="\n")

        for i, row in enumerate(csv.DictReader(input_f), start=1):
            if row["Description"] == "Unassigned":
                continue

            qid = "http-status-codes" + str(i)
            problem = "「%s」を表すHTTPのステータスコードは何か" % (row["Description"],)
            answer = row["Value"]
            answer_kana = answer
            print(problem, answer)

            tsv.writerow([qid, problem, answer, answer_kana])
