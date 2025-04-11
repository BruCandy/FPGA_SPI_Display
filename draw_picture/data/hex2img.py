import numpy as np
import cv2



def hex_to_image(hex_path, output_path):
    with open(hex_path, "r") as f:
        lines = f.readlines()

    pixels = []
    for line in lines:
        hex_val = line.strip()
        b = int(hex_val[0:2], 16)
        g = int(hex_val[2:4], 16)
        r = int(hex_val[4:6], 16)
        pixels.append([b, g, r])

    img = np.array(pixels, dtype=np.uint8).reshape(135, 135, 3)
    img = np.fliplr(img)  # 左右反転
    cv2.imwrite(output_path, img)


if __name__ == "__main__":
    hex_to_image("data/hex/qrcode.hex", "data/jpg/qrcode_debug.jpg")
