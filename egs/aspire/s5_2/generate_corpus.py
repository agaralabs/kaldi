# vim: tabstop=4 shiftwidth=4 expandtab softtabstop=4 ai si

from num2words import num2words as _num2words
import random

def num2words(num):
    r = random.randint(0,1)
    w = _num2words(num)
    w = w.replace('-', ' ').replace(',', '')
    if r and num % 100 > 9:
        w = w.replace('hundred and ', '')
    return w

def generateLine(token, unit1, val1, unit2=None, val2=None):
    line = [token, 'is', num2words(val1), unit1]
    if val2 is not None:
        line.append(num2words(val2))
        if unit2 is not None:
            line.append(unit2)
    print ' '.join(line)

for i in range(1, 7):
    for j in range(0, 12):
        if j == 0:
            generateLine('height', 'feet', i)
        else: 
            generateLine('height', 'feet', i, 'inches', j)

for i in range(10, 150):
    units = ['kg', 'kgs', 'kilogram']
    generateLine('weight', random.choice(units), i)

for i in range(10, 70):
    generateLine('hip size', 'inches', i)

for i in range(10, 70):
    generateLine('waist size', 'inches', i)

for i in range(40, 100):
    generateLine('heart rate', 'beats per minute', i)

for i in range(70, 200):
    for j in range(40, 140):
        generateLine('blood pressure', 'over', i, None, j)

