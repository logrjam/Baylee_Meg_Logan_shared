# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 14:04:45 2026

@author: Logan.Jamison

script to test and load .mat format data
"""

from scipy.io import loadmat

rootpath = "C:/USDA/Work/Code/GitHub/Baylee_Meg_Logan_shared"

rootpath_2 = r"C:\USDA\Work\Code\GitHub\Baylee_Meg_Logan_shared\Data\fwairtempdata"

data = loadmat(rootpath + "/Data/SLCandWEBER/allAprT.mat")

data_2 = loadmat(rootpath_2 + "/allAprT.mat")

equality = data["allAprT"] == data_2["allAprT"]
