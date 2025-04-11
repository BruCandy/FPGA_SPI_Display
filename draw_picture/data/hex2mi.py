def hex_to_mi(hex_path, mi_path, width=24):
    with open(hex_path, "r") as f:
        lines = [line.strip() for line in f if line.strip()]
    depth = len(lines)

    with open(mi_path, "w") as f:
        f.write(f"DEPTH = {depth};\n")
        f.write(f"WIDTH = {width};\n")
        f.write("ADDRESS_RADIX = HEX;\n")
        f.write("DATA_RADIX = HEX;\n")
        f.write("CONTENT BEGIN\n")

        for addr, data in enumerate(lines):
            f.write(f"{addr:05X} : {data};\n")

        f.write("END;\n")


if __name__ == "__main__":
    hex_to_mi("data/hex/girl.hex", "data/mi/girl.mi")
