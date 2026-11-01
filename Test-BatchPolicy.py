"""Read-only regression for bundled legacy batch protection policy."""
from pathlib import Path
import re
p = Path(__file__).parent / 'payload/tools/03_电视精简.bat'
s = p.read_bytes().decode('gb18030')
assert not re.search(r'findstr[^\r\n]*%(?:SAFE_FILE|LAUNCHER_SAFE)%', s, re.I), 'legacy batch still blocks protected packages'
assert 'set SAFE_FILE=' not in s and 'set LAUNCHER_SAFE=' not in s, 'legacy forbidden lists still loaded'
assert 'adb shell pm uninstall --user 0 %PKG%' in s
assert 'adb shell pm disable-user --user 0 %PKG%' in s
assert 'adb shell pm uninstall %PKG%' in s
assert 'installed_packages.txt' in s and 'choice /c 12' in s
print('6 bundled batch policy checks passed; no batch/ADB executed')
