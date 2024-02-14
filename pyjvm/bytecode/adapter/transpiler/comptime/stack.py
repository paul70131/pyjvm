from queue import LifoQueue

class Stack(LifoQueue):

    def push(self, item):
        super().put(item)

    def pop(self):
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
    
    @property
    def depth(self):
        return len(self.queue)