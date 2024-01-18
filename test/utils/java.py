import subprocess

def compile_java(java_file):
    subprocess.check_call(['javac', java_file])
    class_file = java_file.replace(".java", ".class")
    return class_file

