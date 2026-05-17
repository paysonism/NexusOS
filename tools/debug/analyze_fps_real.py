import sys

from pathlib import Path

root = Path(__file__).resolve().parents[2]

with open(root / 'build' / 'test.ppm', 'rb') as f:
    header = b''
    nl_count = 0
    while nl_count < 3:
        char = f.read(1)
        header += char
        if char == b'\n':
            nl_count += 1
    
    # 1024x768 
    # Scan y=8 to 26, x=48 to 100
    stride = 1024 * 3
    print(f"Header: {header.strip()}")
    
    for y in range(8, 26):
        f.seek(len(header) + y * stride + 48 * 3)
        row_data = f.read((100 - 48) * 3)
        line = f"y={y:02d}: "
        for i in range(0, len(row_data), 3):
            r, g, b = row_data[i], row_data[i+1], row_data[i+2]
            if r > 200 and g > 200 and b < 50:
                line += "#"
            else:
                line += "."
        print(line)
