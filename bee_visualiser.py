if __import__('platform').system() == 'Darwin':
    __import__('matplotlib').use('TKAgg') # hack to fix key capture bug on OS X

import numpy as np
import matplotlib.pyplot as plt
import argparse
import json
import os.path
import scipy.io

class Plot(object):
    def __init__(self, image_path, x, y):
        self.image_path = image_path
        self.x = x
        self.y = y

    def __repr__(self):                                                         # d
        return self.__dict__.__repr__()                                         # d

def labels_json_to_plots(labels_json_name, options):
    with open(labels_json_name) as f:
        json_data = json.load(f)['labelled']

    parts = ['head', 'thorax', 'abdomen', 'left antenna', 'right antenna',
        'left wing', 'right antenna']

    return [Plot(os.path.join(os.path.split(labels_json_name)[0], i['path']),
        [i[p][0] for p in parts if i[p] is not None],
        [i['size'][1]-i[p][1] for p in parts if i[p] is not None])
        for i in json_data]

def labels_mat_to_plots(labels_mat_name, options):
    print(options)

def pred_to_plots(pred_name, options):
    image_detections = scipy.io.loadmat(mat_file_name)['boxes']
    image_top_detections = [max(x, key=lambda y: y[-1])
        for x in image_detections]

    return [Plot()]

format_functions = {'labels_json' : labels_json_to_plots,
    'labels_mat' : labels_mat_to_plots,
    'pred' : pred_to_plots}

class PltController(object):
    def __init__(self, plots):
        self.curr_pos = 0
        self.plots = plots

        self.fig = plt.figure()
        self.fig.canvas.mpl_connect('key_press_event', self.key_event)
        im = plt.imread(self.plots[self.curr_pos].image_path)
        self.ax = self.fig.add_subplot(111)
        implot = self.ax.imshow(im)
        self.ax.scatter(self.plots[self.curr_pos].x, self.plots[self.curr_pos].y)
        plt.show()

    def key_event(self, e):
        key_to_offset = {'right' : 1, 'left' : -1}

        key = e.key
        if key in key_to_offset:
            offset = key_to_offset[key]
            self.curr_pos = (self.curr_pos + offset) % len(self.plots)

            self.ax.cla()
            im = plt.imread(self.plots[self.curr_pos].image_path)
            implot = self.ax.imshow(im)
            self.ax.scatter(self.plots[self.curr_pos].x,
                self.plots[self.curr_pos].y)
            self.fig.canvas.draw()

def main():
    parser = argparse.ArgumentParser(
        description='Visualises bee labels and predictions.')
    parser.add_argument('data_format', type=str, help='input file format',
        choices=sorted(format_functions.keys()))
    parser.add_argument('file_name', type=str, help='input file name')
    parser.add_argument("-e", "--episodes", type=str,
                    help="comma-separated episodes in .mat file")
    args = parser.parse_args()

    options = {}
    if args.episodes is not None:
        options['episodes'] = [int(i) for i in args.episodes.split(',')]

    plots = format_functions[args.data_format](args.file_name, options)
    controller = PltController(plots)

if __name__ == '__main__':
    main()