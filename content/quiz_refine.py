# quiz.tsv の中で不適な問題を除外するコード

import csv

Data_input = []

with open('quiz.tsv', encoding='utf-8', newline='') as f:
    for cols in csv.reader(f):
        Data_input.append(cols)
        
Problems = []
Answers = []
Answers_kana = []

NG_Words = ["今年","去年"]

for L in Data_input:
  sentence = L[0]
  index1 = -1
  index2 = -1
  for i in range(len(sentence)):
    if sentence[i] == "\t":
      if index1 == -1:
        index1 = i
      else:
        index2 = i
  problem = sentence[0:index1]
  answer = sentence[index1+1:index2]
  answer_kana = sentence[index2+1:]
  if answer == "" or sentence in NG_Words:
    continue
  Problems.append(problem)
  Answers.append(answer)
  Answers_kana.append(answer_kana)
  
  
Data_output = []
  
for i in range(len(Answers)):
  problem = Problems[i]
  answer = Answers[i]
  answer_kana = Answers_kana[i]
  string = "quiz_database" + "\t" + str(i) +"\t"  + problem + "\t" + answer + "\t" + answer_kana
  Data_output.append([string])

with open("quiz_refine.tsv", "w", encoding="utf_8_sig", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(Data_output)




