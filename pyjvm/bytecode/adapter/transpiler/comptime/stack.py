from queue import LifoQueue

class Stack(LifoQueue):

    def __init__(self, frame=None):
        super().__init__()
        self.frame = frame

    def push(self, item):
        if self.frame:
            self.frame.stackChanged(self.depth + 1, item)
        super().put(item)

    def pop(self):
        if self.frame:
            self.frame.stackChanged(self.depth - 1)
        return super().get_nowait()

    def peek(self):
        return self.queue[-1]

    def __str__(self):
        return str(self.queue)

    def __repr__(self):
        return repr(self.queue)
    
    def copy(self):
        s = Stack()
        s.queue = self.queue.copy()
        return s
    
    def swap(self):
        a = self.pop()
        b = self.pop()
        self.push(a)
        self.push(b)

    def dup_x1(self):
        a = self.pop()
        b = self.pop()
        self.push(a)
        self.push(b)
        self.push(a)
    
    @property
    def depth(self):
        return len(self.queue)