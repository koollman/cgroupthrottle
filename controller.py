#!/usr/bin/env python3

from PID import PID
from subprocess import Popen,PIPE,DEVNULL
import signal

def gen_updater(pid):
    def updater(*args):
        print(args)
        with open("conf/wanted") as config:
            value=config.readline()
            value=int(value)
            print("new setting:", value)
            pid.SetPoint=value*1000
    return updater

def set_handler(updater):
    signal.signal(signal.SIGHUP, updater)

print("Starting")
#with Popen("./sink.sh",stdin=PIPE) as sink,
with Popen("./source.sh",shell=False, stdin=DEVNULL,stdout=PIPE,bufsize=0) as source, \
     Popen("./sink.sh",shell=False,stdin=PIPE,bufsize=0) as sink:

    pid=PID(0.2, 0.1, 0.1)
    pid.setSampleTime(1)
    updater=gen_updater(pid)
    set_handler(updater)
    
    updater()
    print("started")
    for line in source.stdout:
        feedback=int(line)
        print("feedback", feedback/1000)
        pid.update(feedback)
        #print("output:", pid.output)
        setting="%d\n" % pid.output
        #print("setting:", setting)
        sink.stdin.write(setting.encode())
