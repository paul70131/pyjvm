class BytecodeLabel:
    def __init__(self, target: int, size: int):
        self.target = target
        self.offset = 0
        self.size = size
        self.bc_offset = -1

    def resolve(self, offset: int):
        print(f"Resolving label {self.target} to {offset}, {self.bc_offset}")
        self.offset = offset - self.bc_offset + 1

class BytecodeWriter:
    data: list[int]
    bc_offset: int

    def save_labels(self):
        for label in self._labels:
            if label.offset == 0:
                raise Exception(f"Label {label.target} was not resolved")
            
            # write label.offset and label.bc_offset with label.size
            for i in range(label.size):
                self.data[label.bc_offset + i] = label.offset >> (8 * (label.size - i - 1)) & 0xff


    def __init__(self, line_number_table = None):
        self.data = []
        self.bc_offset = 0
        self.line_number_table = line_number_table
        self.line_offset = 1
        self._labels = []

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
        if isinstance(v, BytecodeLabel):
            v.bc_offset = self.size()
            self._labels.append(v)
            v = 0
        self._write(v >> 8)
        self._write(v)

    def s2(self, v: int):
        if isinstance(v, BytecodeLabel):
            v.bc_offset = self.size()
            self._labels.append(v)
            v = 0
        # Ensure v fits into a signed 16-bit integer range (-32768 to 32767)
        if v < -32768 or v > 32767:
            raise ValueError("s2 value out of range")

        # Convert negative values to their 2's complement representation
        if v < 0:
            v = (1 << 16) + v

        # Write the bytes in big-endian order
        self._write((v >> 8) & 0xFF)  # Most significant byte
        self._write(v & 0xFF)   


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