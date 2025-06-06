import os
import shutil

output = 'bin'

if os.path.exists(output):
    shutil.rmtree(output)