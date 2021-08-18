# quiz_refine.tsv の中でITに関するコードのみを抽出
import csv

Data_input = []

with open('quiz_refine.tsv', encoding='utf-8', newline='') as f:
    for cols in csv.reader(f):
        Data_input.append(cols)
    
ID = []
Problems = []
Answers = []
Answers_kana = []

IT_Words = ["インターネット","コンピュータ","ユーザー", "ネットワーク", "パソコン","検索エンジン","ソフトウェア","ウェブサイト","プログラ"]

NG_Words = ["田中角栄","アポトーシス","廬武鉉"] #IT_Wordsを含んでもダメなものを除外

for L in Data_input:
  sentence = L[0]
  index1 = -1
  index2 = -1
  index3 = -1
  for i in range(len(sentence)):
    if sentence[i] == "\t":
      if index1 == -1:
        index1 = i
      elif index2 == -1:
        index2 = i
      else:
        index3 = i
  id = sentence[0:index1]
  problem = sentence[index1+1:index2]
  answer = sentence[index2+1:index3]
  answer_kana = sentence[index3+1:]
  if answer_kana == "":
    continue
    
  flag_NG = 0
  for ng_word in NG_Words:
    if ng_word in sentence:
      flag_NG = 1
  if flag_NG == 1:
    continue
  
  flag_IT = 0
  for it_word in IT_Words:
    if it_word in sentence:
      flag_IT = 1
  if flag_IT == 1:
    ID.append(id)
    Problems.append(problem)
    Answers.append(answer)
    Answers_kana.append(answer_kana)
    print(id,answer)
  
  
Data_output = []
  
for i in range(len(Answers)):
  id = ID[i]
  problem = Problems[i]
  answer = Answers[i]
  answer_kana = Answers_kana[i]
  string = id +"\t"  + problem + "\t" + answer + "\t" + answer_kana
  Data_output.append([string])

with open("quiz_abcgo_IT.tsv", "w", encoding = "utf_8", newline="\n") as f:
    writer = csv.writer(f,lineterminator='\n')
    writer.writerows(Data_output)



