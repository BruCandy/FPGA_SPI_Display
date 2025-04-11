import cv2
import numpy as np



# BGR888 → hex　保存
def bgr888_to_hex(img, output_path):
    with open(output_path, "w") as f:
        for row in img:
            for b, g, r in row:
                f.write(f"{b:02X}{g:02X}{r:02X}\n")  # BGR順


# 三色化
def reduce_to_three_color(img):
    brightness = img.mean(axis=2)
    result = np.zeros_like(img)

    # result[brightness <= 110] = [0, 0, 0]
    # result[(brightness > 110) & (brightness <= 215)] = [206, 106, 118]
    # result[brightness > 215] = [255, 255, 255]

    result[brightness <= 120] = [0, 0, 0]
    result[(brightness > 120) & (brightness <= 200)] = [206, 106, 118]
    result[brightness > 200] = [255, 255, 255]

    # result[brightness <= 130] = [0, 0, 0]
    # result[(brightness > 130) & (brightness <= 210)] = [206, 106, 118]
    # result[brightness > 210] = [255, 255, 255]

    # result[brightness <= 110] = [0, 0, 0]
    # result[brightness > 110] = [255, 255, 255]

    return result


# BGR888 → hex　Top
def image_to_bgr_hex(image_path, output_path, size=(135, 135)):
    img = cv2.imread(image_path) # 画像の読み込み
    img = cv2.resize(img, size) # リサイズ
    img = reduce_to_three_color(img) # 三色化
    img = np.fliplr(img) # 左右反転

    bgr888_to_hex(img, output_path)


if __name__ == "__main__":
    image_to_bgr_hex("data/jpg/qrcode.jpg", "data/hex/qrcode.hex", size=(135, 135))
