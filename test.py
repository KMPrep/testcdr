import requests
import base64
import json
import os
from random import randint
from time import sleep
import sys



headers= {}


def send_line_by_line(filename='', domain='', token='', timeout= 10 ):
    
    # Using readlines()
    file1 = open(filename, 'r')
    Lines = file1.readlines()
    
    count = 1
    # Strips the newline character
    for line in Lines:
        sample = line.strip()
        splits = sample.split(",")
        vals = {}

        innerCount = 1
        for spl in splits:
            vals[str(innerCount)] = spl
            innerCount = innerCount + 1
        
        enc_str = base64.b64encode(bytes(json.dumps(vals)))
        headers= {'token': str(enc_str), 'cnty': 'SG11'}
        print('Send Request: ' + str(count))
        url = 'https://' + domain + '/api/courses'
        r = requests.get(url, headers=headers)
        print(str(enc_str))

        print('Waiting for next request')
        sleep(randint(0, int(timeout)))


        count = count + 1

def send_file(domain='', token=''):
    location = './files'
    for file in os.listdir('./files'):
        #filename = os.fsdecode(file)
        files = {"Logo":  open(location + "/" + file,"rb")}
        payload ={'Token': token}
        url = 'https://' + domain + '/api/courses'
        req = requests.post(url, data=payload, files=files)
        print(req.content)
        


domain = sys.argv[1]
sleeptime = sys.argv[2]
token = sys.argv[3]

for file in os.listdir('./files'):
        #filename = os.fsdecode(file)
        if file.endswith('.csv'):
            print('Sending filename: ' + file)
            send_line_by_line(filename='./files/' + file, domain=domain, token=token, timeout=sleeptime)

send_file(domain=domain, token=token)
