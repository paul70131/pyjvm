

class Locals(list):
    frame: 'Frame'

    def __init__(self, frame: 'Frame', *args, **kwargs):
        self.frame = frame
        super().__init__(*args, **kwargs)

    def copy(self, frame: 'Frame' = None):
        if not frame:
            return super().copy()
        return Locals(frame, super().copy())

    def __setitem__(self, key, value):
        if self.frame:
            self.frame.localChanged(key, value)
        if key >= len(self):
            self.extend([None] * (key - len(self) + 1))
        super().__setitem__(key, value)