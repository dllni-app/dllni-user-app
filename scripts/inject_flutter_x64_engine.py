"""Insert a locally sourced Flutter x86_64 shared library into a DEBUG APK.
The ELF must be ZIP_STORED (not DEFLATED) when extractNativeLibs=false.
The updated APK must be zipaligned and re-signed before installation.
"""
import pathlib
import sys
import zipfile

apk = pathlib.Path(sys.argv[1])
engine = pathlib.Path(sys.argv[2])
lib_path = "lib/x86_64/libflutter.so"
if not apk.is_file() or not engine.is_file():
    raise SystemExit("Missing APK or Flutter engine shared library")
with zipfile.ZipFile(apk, mode="a", allowZip64=True) as archive:
    if lib_path in archive.namelist():
        raise SystemExit("APK already has the x86_64 Flutter engine")
    archive.write(engine, lib_path, compress_type=zipfile.ZIP_STORED)
with zipfile.ZipFile(apk, mode="r") as archive:
    info = archive.getinfo(lib_path)
    if info.compress_type != zipfile.ZIP_STORED:
        raise SystemExit("Native library must use ZIP_STORED")
    print(f"Injected {lib_path}: {info.file_size} bytes, uncompressed")
