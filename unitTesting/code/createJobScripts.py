#!/usr/bin/env python
import sys
import glob
import os
import ntpath
from jinja2 import Environment, FileSystemLoader
from os.path import basename
import itertools as it
import pandas as pd

def expand_grid(*args, **kwargs):
    columns = []
    lst = []
    if args:
        columns += xrange(len(args))
        lst += args
    if kwargs:
        columns += kwargs.iterkeys()
        lst += kwargs.itervalues()
    return pd.DataFrame(list(it.product(*lst)), columns=columns)

if __name__ == '__main__':
    paramGrid = expand_grid(s=[0], i=[0, 1, 2, 3, 4], m=[0, 1, 2],
                            p=[0, 1, 2], o=[2, 5], b=[30],
                            u=[1000], t=['DTLZ1'])


    THIS_DIR = os.path.dirname(os.path.abspath(__file__))

    nrows = paramGrid.shape[0]
    print(nrows)
    validDf = pd.DataFrame()
    for i in range(nrows):
        paramDict = paramGrid.iloc[i, :].to_dict()
        # print(paramDict)
        status1 = False
        status2 = False
        status3 = False
        if (paramDict['i'] == 0 and paramDict['m'] == 0) or (paramDict['i'] != 0 and paramDict['m'] != 0):
            status1 = True
        if (paramDict['p'] == 1 and paramDict['i'] == 0) or (paramDict['p'] != 1 and paramDict['i'] != 0):
            status2 = True
        if (paramDict['p'] == 2 and paramDict['i'] == 4) or (paramDict['p'] != 2 and paramDict['i'] != 4):
            status3 = True
        if status1 and status2 and status3:
            validRow = paramGrid.iloc[i, :]
            print(validRow)
            validDf = validDf.append(validRow, ignore_index=True)

    print(paramGrid.shape[0])
    print(validDf.shape[0])
    print(validDf)
    nrows = validDf.shape[0]
    for i in range(nrows):
        paramDict = validDf.iloc[i, :].to_dict()
        paramDict['n'] = paramDict['o']
        paramDict['id'] = '%05d-%s' % (i, paramDict['t'])
        print(paramDict)
        env = Environment(loader=FileSystemLoader(THIS_DIR), trim_blocks=False)
        tname = 'runExp.template'
        jobScript = env.get_template(tname).render(paramDict=paramDict)
        bname = paramDict['id']
        jobFilename = 'job_%s.job' % bname
        with open(jobFilename, "w") as text_file:
            text_file.write(jobScript)
            text_file.write('\n')
