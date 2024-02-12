adapters = []

from pyjvm.bytecode.adapter.method_link.method_link_adapter import MethodLinkAdapter
from pyjvm.bytecode.adapter.transpiler.transpiler_adapter import TranspilerAdapter


adapters.append(TranspilerAdapter()) # first since its more desireable
#adapters.append(MethodLinkAdapter())