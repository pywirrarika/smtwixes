# -*- coding:utf-8 -*-
# Author: Jesús Mager
# GPL v.3+
# 2015

import graphviz as gv
from wixaffixes import pre, post
# Todos los parámetros son listas o tuplas
# donde:
#  * alfabeto:  es el alfabeto aceptado por el 
#               autómata.
#  * estados:   es una lista de estados aceptados
#               por el autómata.
#  * inicio:    Son los estados de inicio del fsm.
#  * trans:     Es una tupla de funciones de transición
#               con tres elementos que son: (a,b,c) donde
#               (a,b) son los estados de partida y llegada;
#               mientras que c es la letra que acepta.
#  * final      Son los estados finales del autómata.

def draw(alfabeto, estados, inicio, trans, final):
    print("inicio:", str(inicio))
    g = gv.Digraph(format='svg')
    g.graph_attr['rankdir'] = 'LR'
    g.node('ini', shape="point")
    for e in estados:
        if e in final:
            g.node(e, shape="doublecircle")
        else:
            g.node(e)
        if e in inicio:
            g.edge('ini',e)

    for t in trans:
        #if t[2] not in alfabeto:
        #    return 0
        g.edge(t[0], t[1], label=str(t[2]))
    g.render(view=True)

# Ejemplo de uso

if __name__ == '__main__':
    
    post = post[::-1]
    affixes = []
    for x in pre:
        x.append("ε")
    for x in post:
        x.append("ε")


    for x in pre:
        affixes = affixes + x
    for x in post:
        affixes = affixes + x
    alf = list(set(affixes+["stem"]))
    print(alf)

    estados = ["p"+str(18-x) for x in range(len(pre))] + ["S"] + ["s"+str(x) for x in range(len(post))]+["F"]
    print("States",estados)
    trans = []
    i = 0
    for p in pre:
        for a in p:
            if a == "ε":
                trans.append((estados[i], estados[i+1],a+":"+a))
            else:
                trans.append((estados[i], estados[i+1],a+":|"+a+"|"))
        i=i+1
    trans.append(("S","s0","stem"))
    i=i+1
    for p in post:
        for a in p:
            if a == "ε":
                trans.append((estados[i], estados[i+1],a+":"+a))
            else:
                trans.append((estados[i], estados[i+1],a+":|"+a+"|"))
        i=i+1


    print("Transiciones", trans)
    inicial = [estados[0]]
    terminal = (estados[-1])

    draw(alf, estados, inicial, trans, terminal)
