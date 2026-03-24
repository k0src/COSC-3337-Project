from pathlib import Path

import numpy as np
from PIL import Image

SOURCE_FOLDER = Path(r"C:\Users\clips\!Code\COSC-3337\data\user_self_drift\plots")

TOLERANCE = 10

IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".bmp", ".tiff", ".webp"}


def autocrop_image(image: Image.Image, tolerance: int = TOLERANCE) -> Image.Image:
    img_array = np.array(image.convert("RGB"))

    row_variance = np.var(img_array, axis=(1, 2))
    rows_with_content = np.where(row_variance > tolerance)[0]

    col_variance = np.var(img_array, axis=(0, 2))
    cols_with_content = np.where(col_variance > tolerance)[0]

    if len(rows_with_content) == 0 or len(cols_with_content) == 0:
        return image

    top = rows_with_content[0]
    bottom = rows_with_content[-1] + 1
    left = cols_with_content[0]
    right = cols_with_content[-1] + 1

    return image.crop((left, top, right, bottom))


def main() -> None:
    source = SOURCE_FOLDER

    image_paths = [
        p
        for p in source.iterdir()
        if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    ]

    if not image_paths:
        print(f"No images found in: {source}")
        return

    for image_path in image_paths:
        with Image.open(image_path) as img:
            cropped = autocrop_image(img)
            fmt = img.format
            cropped.save(image_path, format=fmt)

            print(f"Cropped: {image_path}")


if __name__ == "__main__":
    main()
