What we call a "Method Link" is basically registering the python method as such and calling the VarArgs Method
pyjvm.java.Bridge.call_link(link_id, Object[] args)

the link_id is then resolved to the method, the arguments converted according to the method signature and the method called.
This is the slower aproach but it is also the most flexible one and allows for all python features to be used.