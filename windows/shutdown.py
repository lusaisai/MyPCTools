import subprocess
import sys
from time import sleep


class Shutdown:
    def __init__(self, time=60):
        self._time = int(time) * 60

    def set(self):
        subprocess.check_output(['shutdown', '/s', '/t', str(self._time)])

    @staticmethod
    def cancel():
        subprocess.check_output(['shutdown', '/a'])

    def ask_time(self):
        while True:
            print("Please enter the minutes(default an hour) after which to turn off the computer.")
            print("Type c to cancel the previous shutdown schedule.")
            time = sys.stdin.readline().strip()
            if time == "c":
                Shutdown.cancel()
                break

            if time == "":
                self.set()
                break

            if time != 0:
                self._time = int(time) * 60
                self.set()
                break


s = Shutdown()
s.ask_time()
print("This window will be closed after 1 second")
sleep(1)
