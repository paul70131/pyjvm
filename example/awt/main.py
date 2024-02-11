from pyjvm.jvm import Jvm
from pyjvm.bytecode.annotations import Method, Override

import time

jvm = Jvm.acquire()

jvm._export_generated_classes = True

# Import necessary Java classes
Frame = jvm.findClass("java/awt/Frame")
Label = jvm.findClass("java/awt/Label")

class MyFrame(Frame):
    package = "example.awt"

    @Method
    def __init__(self):
        # Set frame properties
        self.setTitle("PyJVM AWT Example")
        self.setSize(300, 200)

        # Create a label
        label = Label("Hello, PyJVM!")
        label.setBounds(50, 50, 200, 50)

        # Add label to the frame
        self.add(label)

        # Set frame layout
        self.setLayout(None)

        # Make frame visible
        self.setVisible(True)

if __name__ == "__main__":
    # Create an instance of MyFrame
    my_frame = MyFrame()
    time.sleep(5)
