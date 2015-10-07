import scipy.io
import numpy as np

class Rectangle(object):
    def __init__(self, mat_array):
        self.x1, self.x2, self.y1, self.y2 = mat_array
        self.centre = (self.x1+self.x2)/2, (self.y1+self.y2)/2

class Detection(object):
    def __init__(self, mat_array):
        self.component = mat_array[-2]
        self.score = mat_array[-1]
        self.rectangles = [Rectangle(mat_array[i:i+4])
                           for i in range((len(mat_array)-2)//4)]

class ImageResult(object):
    def __init__(self, mat_array):
        self.detections = [Detection(i) for i in mat_array]
        self.detections.sort(key=lambda x: x.score, reverse=True)

class Results(object):
    def __init__(self, mat_file_name):
        mat_data = scipy.io.loadmat(mat_file_name)

        boxes = mat_data['boxes']

        self.image_results = [ImageResult(i) for i in boxes[0]]