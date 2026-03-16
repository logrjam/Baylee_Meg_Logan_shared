# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 14:04:45 2026

@author: Logan.Jamison

script to test and load .mat format data
"""

from scipy.io import loadmat

rootpath = "C:/USDA/Work/Code/GitHub/Baylee_Meg_Logan_shared"

data = loadmat(rootpath + "/Data/LoganUpdatedMeltMetrics/allmeltrate.mat")
