from pyjvm.jvm import Jvm
from pyjvm.bytecode.annotations import Method, Override

jvm = Jvm.acquire()

# Import necessary Java classes
Frame = jvm.findClass("java/awt/Frame")
Label = jvm.findClass("java/awt/Label")

class MyFrame(Frame):

    @Method
    def __init__(self, title: str):
        # Call the constructor of the superclass
        Frame.__init__(self)
        
        # Set frame properties
        self.setTitle(title)
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
    my_frame = MyFrame("PyJVM AWT Example")
