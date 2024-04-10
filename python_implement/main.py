import cv2
import numpy as np
from color_model import *

image_path = "../radishes.jpg"
image = cv2.imread(image_path)

image_np = np.array(image)

estimate_color_model(image_np,8)
