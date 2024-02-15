from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeUninitialized, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeActualFloat, ComptimeString, ComptimePyObject, ComptimeActualDouble, ComptimeActualLong, ComptimeActualInt, ComptimeNull

class BC:
    opcodes = {}
    " A java bytecode"
    opcode: int
    width: int
    visited: bool

    def execute(self, frame, data: bytes, cp):
        pass

    def __init__(self):
        self.visited = False

    def do_execute(self, frame, data, cp):
        self.execute(frame, data, cp)
        frame.pc += self.width
        self.visited = True

    def __init_subclass__(cls) -> None:
        if hasattr(cls, "opcode"):
            BC.opcodes[cls.opcode] = cls

    @staticmethod
    def from_opcode(opcode):
        return BC.opcodes[opcode]()

class SimpleBC(BC):
    puts: list = []
    pops: int = 0
    " A simple bytecode that doesn't require any special handling. First pops (pops) ammount, then puts each item in puts"
    def execute(self, frame, data: bytes, cp):
        for _ in range(self.pops):
            frame.stack.pop()
        for put in self.puts:
            frame.stack.push(put())

class XLOAD(BC):
    width = 2
    " Load reference from local variable"

    def execute(self, frame, data: bytes, cp):
        index = int.from_bytes(data, "big")
        frame.stack.push(frame.locals[index])

class ALOAD(XLOAD):
    opcode = Opcodes.ALOAD

class ILOAD(XLOAD):
    opcode = Opcodes.ILOAD

class FLOAD(XLOAD):
    opcode = Opcodes.FLOAD

class LLOAD(XLOAD):
    opcode = Opcodes.LLOAD

class DLOAD(XLOAD):
    opcode = Opcodes.DLOAD


class XLOAD_X(XLOAD):
    width = 1
    index: int
    " Load reference from local variable 0"

    def execute(self, frame, data: bytes, cp):
        frame.stack.push(frame.locals[self.index])

class ALOAD_0(XLOAD_X):
    opcode = Opcodes.ALOAD_0
    index = 0

class ALOAD_1(XLOAD_X):
    opcode = Opcodes.ALOAD_1
    index = 1

class ALOAD_2(XLOAD_X):
    opcode = Opcodes.ALOAD_2
    index = 2

class ALOAD_3(XLOAD_X):
    opcode = Opcodes.ALOAD_3
    index = 3

class ILOAD_0(XLOAD_X):
    opcode = Opcodes.ILOAD_0
    index = 0

class ILOAD_1(XLOAD_X):
    opcode = Opcodes.ILOAD_1
    index = 1

class ILOAD_2(XLOAD_X):
    opcode = Opcodes.ILOAD_2
    index = 2

class ILOAD_3(XLOAD_X):
    opcode = Opcodes.ILOAD_3
    index = 3

class FLOAD_0(XLOAD_X):
    opcode = Opcodes.FLOAD_0
    index = 0

class FLOAD_1(XLOAD_X):
    opcode = Opcodes.FLOAD_1
    index = 1

class FLOAD_2(XLOAD_X):
    opcode = Opcodes.FLOAD_2
    index = 2

class FLOAD_3(XLOAD_X):
    opcode = Opcodes.FLOAD_3
    index = 3

class LLOAD_0(XLOAD_X):
    opcode = Opcodes.LLOAD_0
    index = 0

class LLOAD_1(XLOAD_X):
    opcode = Opcodes.LLOAD_1
    index = 1

class LLOAD_2(XLOAD_X):
    opcode = Opcodes.LLOAD_2
    index = 2

class LLOAD_3(XLOAD_X):
    opcode = Opcodes.LLOAD_3
    index = 3

class DLOAD_0(XLOAD_X):
    opcode = Opcodes.DLOAD_0
    index = 0

class DLOAD_1(XLOAD_X):
    opcode = Opcodes.DLOAD_1
    index = 1

class DLOAD_2(XLOAD_X):
    opcode = Opcodes.DLOAD_2
    index = 2

class DLOAD_3(XLOAD_X):
    opcode = Opcodes.DLOAD_3
    index = 3

class XSTORE(BC):
    width = 2
    " Store reference into local variable"

    def execute(self, frame, data: bytes, cp):
        index = int.from_bytes(data[:2], "big", signed=False)
        frame.locals[index] = frame.stack.pop()

class ASTORE(XSTORE):
    opcode = Opcodes.ASTORE

class ISTORE(XSTORE):
    opcode = Opcodes.ISTORE

class FSTORE(XSTORE):
    opcode = Opcodes.FSTORE

class LSTORE(XSTORE):
    opcode = Opcodes.LSTORE

class DSTORE(XSTORE):
    opcode = Opcodes.DSTORE

class XSTORE_X(XSTORE):
    width = 1
    index: int
    " Store reference into local variable 0"

    def execute(self, frame, data: bytes, cp):
        frame.locals[self.index] = frame.stack.pop()

class ASTORE_0(XSTORE_X):
    opcode = Opcodes.ASTORE_0
    index = 0

class ASTORE_1(XSTORE_X):
    opcode = Opcodes.ASTORE_1
    index = 1

class ASTORE_2(XSTORE_X):
    opcode = Opcodes.ASTORE_2
    index = 2

class ASTORE_3(XSTORE_X):
    opcode = Opcodes.ASTORE_3
    index = 3

class ISTORE_0(XSTORE_X):
    opcode = Opcodes.ISTORE_0
    index = 0

class ISTORE_1(XSTORE_X):
    opcode = Opcodes.ISTORE_1
    index = 1

class ISTORE_2(XSTORE_X):
    opcode = Opcodes.ISTORE_2
    index = 2

class ISTORE_3(XSTORE_X):
    opcode = Opcodes.ISTORE_3
    index = 3

class FSTORE_0(XSTORE_X):
    opcode = Opcodes.FSTORE_0
    index = 0

class FSTORE_1(XSTORE_X):
    opcode = Opcodes.FSTORE_1
    index = 1

class FSTORE_2(XSTORE_X):
    opcode = Opcodes.FSTORE_2
    index = 2

class FSTORE_3(XSTORE_X):
    opcode = Opcodes.FSTORE_3
    index = 3

class LSTORE_0(XSTORE_X):
    opcode = Opcodes.LSTORE_0
    index = 0

class LSTORE_1(XSTORE_X):
    opcode = Opcodes.LSTORE_1
    index = 1

class LSTORE_2(XSTORE_X):
    opcode = Opcodes.LSTORE_2
    index = 2

class LSTORE_3(XSTORE_X):
    opcode = Opcodes.LSTORE_3
    index = 3

class DSTORE_0(XSTORE_X):
    opcode = Opcodes.DSTORE_0
    index = 0

class DSTORE_1(XSTORE_X):
    opcode = Opcodes.DSTORE_1
    index = 1

class DSTORE_2(XSTORE_X):
    opcode = Opcodes.DSTORE_2
    index = 2

class DSTORE_3(XSTORE_X):
    opcode = Opcodes.DSTORE_3
    index = 3

class POP(SimpleBC):
    opcode = Opcodes.POP
    width = 1
    pops = 1

class BIPUSH(SimpleBC):
    opcode = Opcodes.BIPUSH
    width = 2
    puts = [ComptimeActualInt]

class SIPUSH(SimpleBC):
    opcode = Opcodes.SIPUSH
    width = 3
    puts = [ComptimeActualInt]

class ANEWARRAY(BC):
    opcode = Opcodes.ANEWARRAY
    width = 3

    def execute(self, frame, data: bytes, cp):
        frame.stack.pop()
        frame.stack.push(ComptimeList("java/lang/Object"))

class DUP(BC):
    opcode = Opcodes.DUP
    width = 1

    def execute(self, frame, data: bytes, cp):
        v = frame.stack.pop()
        frame.stack.push(v)
        frame.stack.push(v)

class DUP_X1(BC):
    opcode = Opcodes.DUP_X1
    width = 1

    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        frame.stack.push(a)
        frame.stack.push(b)
        frame.stack.push(a)

class DUP_X2(BC):
    opcode = Opcodes.DUP_X2
    width = 1

    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        c = frame.stack.pop()
        frame.stack.push(a)
        frame.stack.push(c)
        frame.stack.push(b)
        frame.stack.push(a)

class DUP2(BC):
    opcode = Opcodes.DUP2
    width = 1

    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        frame.stack.push(b)
        frame.stack.push(a)
        frame.stack.push(b)
        frame.stack.push(a)

class DUP2_X1(BC):
    opcode = Opcodes.DUP2_X1
    width = 1

    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        c = frame.stack.pop()
        frame.stack.push(b)
        frame.stack.push(a)
        frame.stack.push(c)
        frame.stack.push(b)
        frame.stack.push(a)

class DUP2_X2(BC):
    opcode = Opcodes.DUP2_X2
    width = 1

    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        c = frame.stack.pop()
        d = frame.stack.pop()
        frame.stack.push(b)
        frame.stack.push(a)
        frame.stack.push(d)
        frame.stack.push(c)
        frame.stack.push(b)
        frame.stack.push(a)

class XASTORE(BC):
    opcode: int
    width = 1

    def execute(self, frame, data: bytes, cp):
        value = frame.stack.pop()
        index = frame.stack.pop()
        array = frame.stack.pop()

class AASTORE(XASTORE):
    opcode = Opcodes.AASTORE

class IASTORE(XASTORE):
    opcode = Opcodes.IASTORE

class FASTORE(XASTORE):
    opcode = Opcodes.FASTORE

class LASTORE(XASTORE):
    opcode = Opcodes.LASTORE

class DASTORE(XASTORE):
    opcode = Opcodes.DASTORE

class BASTORE(XASTORE):
    opcode = Opcodes.BASTORE

class CASTORE(XASTORE):
    opcode = Opcodes.CASTORE

class SASTORE(XASTORE):
    opcode = Opcodes.SASTORE

class XALOAD(BC):
    opcode: int
    width = 1

    def execute(self, frame, data: bytes, cp):
        index = frame.stack.pop()
        array = frame.stack.pop()
        frame.stack.push(self.type())

class AALOAD(XALOAD):
    opcode = Opcodes.AALOAD
    type = ComptimeObject

class IALOAD(XALOAD):
    opcode = Opcodes.IALOAD
    type = ComptimeActualInt

class FALOAD(XALOAD):
    opcode = Opcodes.FALOAD
    type = ComptimeActualInt

class LALOAD(XALOAD):
    opcode = Opcodes.LALOAD
    type = ComptimeActualLong

class DALOAD(XALOAD):
    opcode = Opcodes.DALOAD
    type = ComptimeActualDouble

class BALOAD(XALOAD):
    opcode = Opcodes.BALOAD
    type = ComptimeActualInt

class CALOAD(XALOAD):
    opcode = Opcodes.CALOAD
    type = ComptimeActualInt

class SALOAD(XALOAD):
    opcode = Opcodes.SALOAD
    type = ComptimeActualInt

class XRETURN(BC):
    opcode: int
    width = 1

    def execute(self, frame, data: bytes, cp):
        frame.returned = True

class ARETURN(XRETURN):
    opcode = Opcodes.ARETURN

class IRETURN(XRETURN):
    opcode = Opcodes.IRETURN

class FRETURN(XRETURN):
    opcode = Opcodes.FRETURN

class LRETURN(XRETURN):
    opcode = Opcodes.LRETURN

class DRETURN(XRETURN):
    opcode = Opcodes.DRETURN

class RETURN(XRETURN):
    opcode = Opcodes.RETURN

class CHECKCAST(SimpleBC):
    opcode = Opcodes.CHECKCAST
    width = 3

class INVOKEX(BC):

    def _execute(self, frame, args, ret, cp):
        for _ in args:
            frame.stack.pop()
        
        if ret == "F":
            frame.stack.push(ComptimeActualFloat())
        elif ret == "D":
            frame.stack.push(ComptimeActualDouble())
        elif ret == "J":
            frame.stack.push(ComptimeActualLong())
        elif ret in ["Z", "B", "C", "S", "I"]:
            frame.stack.push(ComptimeActualInt())
        elif ret == "V":
            pass
        else:
            frame.stack.push(ComptimeObject(ret[1:-1]))
    
    def _get_signature(self, cp, data):
        index = int.from_bytes(data[0:2], "big")
        entry = cp.get(index - 1)
        name, sig = entry.signature(cp)
        sig = str(sig)[1:]
        args, ret = sig.split(")")
        arglen = 0
        in_arg = False
        arg = ""
        argsl = []
        for c in args:
            if c == "[":
                continue
            if c == "L":
                in_arg = True
                continue
            if c == ";":
                in_arg = False
                continue
            arg += c
            if not in_arg:
                argsl.append(arg)
                arg = ""
        if arg:
            argsl.append(arg)
        
        return ret, argsl

class INVOKESPECIAL(INVOKEX):
    opcode = Opcodes.INVOKESPECIAL
    width = 3

    def execute(self, frame, data: bytes, cp):
        frame.stack.pop()
        signature = self._get_signature(cp, data)
        self._execute(frame, signature[1], signature[0], cp)
    
class INVOKEVIRTUAL(INVOKEX):
    opcode = Opcodes.INVOKEVIRTUAL
    width = 3

    def execute(self, frame, data: bytes, cp):
        frame.stack.pop()
        signature = self._get_signature(cp, data)
        self._execute(frame, signature[1], signature[0], cp)

class INVOKEINTERFACE(INVOKEX):
    opcode = Opcodes.INVOKEINTERFACE
    width = 5

    def execute(self, frame, data: bytes, cp):
        frame.stack.pop()
        signature = self._get_signature(cp, data)
        self._execute(frame, signature[1], signature[0], cp)

class INVOKESTATIC(INVOKEX):
    opcode = Opcodes.INVOKESTATIC
    width = 3

    def execute(self, frame, data: bytes, cp):
        signature = self._get_signature(cp, data)
        self._execute(frame, signature[1], signature[0], cp)


class ACONST_NULL(SimpleBC):
    opcode = Opcodes.ACONST_NULL
    width = 1
    puts = [ComptimeNull]

class ARRAYLENGTH(SimpleBC):
    opcode = Opcodes.ARRAYLENGTH
    width = 1
    pops = 1
    puts = [ComptimeActualInt]

class LDC2_W(BC):
    opcode = Opcodes.LDC2_W
    width = 3

    def execute(self, frame, data: bytes, cp):
        # TODO Check if double or long
        frame.stack.push(ComptimeLong())

class LDC_W(BC):
    opcode = Opcodes.LDC_W
    width = 2

    def execute(self, frame, data: bytes, cp):
        # TODO Check if int or someting else, will always be string for now since thats how it's used
        frame.stack.push(ComptimeString())

class NOP(SimpleBC):
    opcode = Opcodes.NOP
    width = 1

class NEW(SimpleBC):
    opcode = Opcodes.NEW
    width = 3
    puts = [ComptimeUninitialized]

class SWAP(BC):
    opcode = Opcodes.SWAP
    width = 1
    
    def execute(self, frame, data: bytes, cp):
        a = frame.stack.pop()
        b = frame.stack.pop()
        frame.stack.push(a)
        frame.stack.push(b)

class IFEQ(SimpleBC):
    opcode = Opcodes.IFEQ
    width = 3
    pops = 1

class GOTO(SimpleBC):
    opcode = Opcodes.GOTO
    width = 3

    def do_execute(self, frame, data, cp):
        offset = int.from_bytes(data, "big", signed=True)
        frame.pc += offset
        self.visited = True