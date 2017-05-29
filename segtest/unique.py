import random

S = list(open("segmentedtest.wix").read().split("\n"))
N = list(open("nonsegmentedtest.wix").read().split("\n"))

cont = []

for i in range(len(S)):
    try:
        cont.append((S[i], N[i]))
    except IndexError:
        print(i)
        break

contset=list(set(cont))

Swtr = open("trainseg.wix", "w")
Nwtr = open("trainnseg.wix", "w")

Swte = open("testseg.wix", "w")
Nwte = open("testnseg.wix", "w")

random.seed(42)
unique_corpus = set(contset)
print("Total corpus:", str(len(unique_corpus)))
test = set(random.sample(unique_corpus, k=400))
print("Test set:", str(len(test)))
train = unique_corpus - test
print("Train set:", str(len(train)))

for c in list(test):
    print(c[0], file=Swte)
    print(c[1], file=Nwte)


for c in list(train):
    print(c[0], file=Swtr)
    print(c[1], file=Nwtr)



