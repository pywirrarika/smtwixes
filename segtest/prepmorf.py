
S = open("trainseg.wix")
N = open("trainnseg.wix")


St = open("testseg.wix")
Nt = open("testnseg.wix")


mF = open("morfguided.wix", "w")
gS = open("goldstandard.wix", "w")

while S:
    s = S.readline().replace("\n","")
    n = N.readline().replace("\n","")
    if s == "" or n == "":
        break

    print(n, ", ", s, sep="", file=mF)

while S:
    st = St.readline().replace("\n","")
    nt = Nt.readline().replace("\n","")
    if st == "" or nt == "":
        break

    print(nt, ", ", st, sep="", file=gS)



