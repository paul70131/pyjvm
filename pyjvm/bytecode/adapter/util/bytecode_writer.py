class BytecodeWriter:
    data: list[int]
    bc_offset: int

    def __init__(self):
        self.data = []
        self.bc_offset = 0

    def _write(self, v:int):
        if v > 0xff:
            raise Exception("BytecodeWriter._write: value too large")
        self.data.append(v)

    def bc(self, v:int):
        self._write(v)
        self.bc_offset += 1

    def u1(self, v:int):
        self._write(v)

    def u2(self, v:int):
        self._write(v >> 8)
        self._write(v)

    def u4(self, v:int):
        self._write(v >> 24)
        self._write(v >> 16)
        self._write(v >> 8)
        self._write(v)

    def u8(self, v:int):
        self._write(v >> 56)
        self._write(v >> 48)
        self._write(v >> 40)
        self._write(v >> 32)
        self._write(v >> 24)
        self._write(v >> 16)
        self._write(v >> 8)
        self._write(v)

    def bytes(self) -> bytes:
        return bytes(self.data)
    
    def size(self) -> int:
        return len(self.data)