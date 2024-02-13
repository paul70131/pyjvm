class BytecodeWriter:
    data: list[int]
    bc_offset: int

    def __init__(self, line_number_table):
        self.data = []
        self.bc_offset = 0
        self.line_number_table = line_number_table
        self.line_offset = 1

    def nextLine(self, line:int = -1):
        if line == -1:
            line = self.line_offset + 1
        self.line_number_table.append(self.bc_offset, line)
        self.line_offset = line

    def _write(self, v:int):
        if v < 0 or v > 0xff:
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