from distutils.command.build import build
from distutils.command.build_ext import build_ext
import warnings
from setuptools import setup, Extension, find_packages

from Cython.Build import cythonize

import platform
import os
import shutil
import subprocess

extensions = [
    Extension(
        'pyjvm.jvm',
        ['pyjvm/jvm.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ), 
    Extension(
        'pyjvm.types.clazz.jvmclass',
        ['pyjvm/types/clazz/jvmclass.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.jvmfield',
        ['pyjvm/types/clazz/jvmfield.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.jvmmethod',
        ['pyjvm/types/clazz/jvmmethod.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.signature',
        ['pyjvm/types/signature.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.exceptions.exception',
        ['pyjvm/exceptions/exception.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.object.jvmboundfield',
        ['pyjvm/types/object/jvmboundfield.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.object.jvmboundmethod',
        ['pyjvm/types/object/jvmboundmethod.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.converter.typeconverter',
        ['pyjvm/types/converter/typeconverter.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmstring',
        ['pyjvm/types/clazz/special/jvmstring.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmenum',
        ['pyjvm/types/clazz/special/jvmenum.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmexception',
        ['pyjvm/types/clazz/special/jvmexception.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.array.jvmarray',
        ['pyjvm/types/array/jvmarray.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.jvmbytecodeclass',
        ['pyjvm/bytecode/jvmbytecodeclass.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodefields',
        ['pyjvm/bytecode/components/jvmbytecodefields.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodemethods',
        ['pyjvm/bytecode/components/jvmbytecodemethods.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeattributes',
        ['pyjvm/bytecode/components/jvmbytecodeattributes.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeconstantpool',
        ['pyjvm/bytecode/components/jvmbytecodeconstantpool.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeinterfaces',
        ['pyjvm/bytecode/components/jvmbytecodeinterfaces.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.base',
        ['pyjvm/bytecode/components/base.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
]

JAVA_HOME = os.environ.get("JAVA_HOME", None)

setup(
    name='pyjvm',
    description="Python Bindings for the JVM (jni & jvmti)",
    ext_modules=cythonize(extensions, language_level=3, build_dir="build/c"),
    packages=find_packages("pyjvm/src"),
    package_dir={'pyjvm': 'pyjvm'},
    #b
    include_dirs=[
        "./pyjvm/src",
        "./pyjvm/src/c/headers",
        JAVA_HOME + "/include",
        JAVA_HOME + "/include/win32",
    ],
    zip_safe=False,
    version='0.0.2',
    author="Paul K."
)