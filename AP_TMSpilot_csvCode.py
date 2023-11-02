# Created by Ashley Pelton
# Code for extracting relevant values from CSV file
# 
# Two Outputs:
# CSV file including relevant values split into columns
# XLSX file including original CSV file and relevant values split into two different sheets
#
# TO MODIFY WHEN USING ***********************************************************************************
# Line 19: alter tmsFile variable to be the filepath to the CSV
# Line 80: alter name of .csv 'TMSfMRI-NAVXX.csv' to include NAV Participant ID
# Line 83: alter name of .xlsx spreadsheet 'TMSfMRI-NAVXX-Combined.xlsx' to include NAV Participant ID
# ********************************************************************************************************

import csv
import pandas as pd
from datetime import datetime, timedelta

# MODIFY: Replace with name of CSV file to be manipulated
tmsFile='/Users/ashleypelton/Downloads/output.csv'

# Create formatted .xlsx file separating contents of CSV file into cells
df1 = pd.read_csv(tmsFile, delimiter=' ', header=None)

combined = 'TMSfMRI-NAVXX-Combined.xlsx'

with pd.ExcelWriter(combined, engine='openpyxl') as writer:
    df1.to_excel(writer, sheet_name='Initial CSV', index=False)

# Columns of relevant data to be obtained from initial CSV
TMSColumn = []
TTLCounter = []
TotalTTL = []
Blocks = []
TimeStamp = []
Time = []

print(TMSColumn)

# Iterates through the current CSV, pulling relevant data
# ALTER TO READ THROUGH THE .XLSX FILE RATHER THAN CSV
pulse = 1
with open(tmsFile, mode='r') as file:
    reader = csv.reader(file)
    for row in reader:
        if row[0] == "t":
            Blocks.append("OFF")
        elif row[0] == ">>>":
            if row[1] == "t":
                Blocks.append("ON")
        elif row[0] == "PULSE!":
            Blocks.append("ON")
        for i in range(len(row)):
            if row[i] == 'Timestamp:':
                if i + 1 < len(row):
                    strTime = row[i+1]
                    timeFormat = "%H:%M:%S"
                    """Will need to add .%f later"""
                    numTime = datetime.strptime(strTime, timeFormat)
                    """Need to format numTime differently"""
                    TimeStamp.append(strTime)
                    if len(TimeStamp) != 0:
                        initial = datetime.strptime(TimeStamp[0], timeFormat)
                        Time.append((numTime - initial).total_seconds())
                    else:
                        Time.append(numTime - numTime)
            elif row[i] == 'TTL:':
                if i + 1 < len(row):
                    TTLCounter.append(row[i + 1])
                    TotalTTL.append(pulse)
                    pulse += 1
                    TMSColumn.append('N')
            elif row[i] == 'TMS:':
                if i + 1 < len(row):
                    TMSColumn.append('Y')
                    TTLCounter.append('P')
                    TotalTTL.append('P')

# Initial CSV converted to a DF for the combined CSV file
# df1 = pd.read_csv(tmsFile)

# Relevant data values separated into columns
data = { 'TMS (Y/N)' : TMSColumn,
         'TTL Counter' : TTLCounter,
         'Total TTL' : TotalTTL,
         'Blocks' : Blocks,
         'Timestamp' : TimeStamp,
         'Time/Duration (Seconds)' : Time}
df2 = pd.DataFrame(data)
  
# Creates combined CSV file
# MODIFY: Name of .csv file
df2.to_csv('TMSfMRI-NAVXX.csv', index=False)

# Creates xlsx file with two sheets
# MODIFY: Name of .xlsx file
with pd.ExcelWriter('TMSfMRI-NAVXX-Combined.xlsx', engine='openpyxl') as writer:
    df2.to_excel(writer, sheet_name='All Values', index=False)"""