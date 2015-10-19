if __import__('platform').system() == 'Darwin':
    __import__('matplotlib').use('TKAgg') # hack to fix key capture bug on OS X

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.markers as markers
import argparse
import json
import os, os.path
import scipy.io
from detection_reader import Results

markers = {7: ['o', 'o', 'o', '<', '>', '<', '>'], 3: ['o','o','o']}
colours = {7: ['r', 'g', 'b', 'c', 'c' ,'y', 'y'], 3: ['r','g','b']}

class Plot(object):
    def __init__(self, image_path, x, y, amarkers=None, acolours=None):
        self.image_path = image_path
        self.x = x
        self.y = y
        self.markers = len(x)*['o'] if amarkers is None else amarkers
        self.colours = len(x)*['b'] if acolours is None else acolours

def labels_json_to_plots(labels_json_name, options):
    with open(labels_json_name) as f:
        json_data = json.load(f)['labelled']

    parts = ['head', 'thorax', 'abdomen', 'left antenna', 'right antenna',
        'left wing', 'right wing']

    return [Plot(os.path.join(os.path.split(labels_json_name)[0], i['path']),
        [i[p][0] for p in parts if i[p] is not None],
        [i['size'][1]-i[p][1] for p in parts if i[p] is not None])
        for i in json_data]

def labels_mat_to_plots(labels_mat_name, options):
    image_files = [os.path.join(options.directory, x)
        for x in sorted([y for y in os.listdir(options.directory)
                if y.split('.')[-1].lower() == 'jpg'],
            key=lambda x: int(x.split('.')[0]))]
    label_array = scipy.io.loadmat(labels_mat_name)['labels']
    return [Plot(image_files[i],
        list(label_array[:,0,i]),
        list(label_array[:,1,i]))
        for i in range(label_array.shape[2])
        if i < len(image_files)]

def pred_to_plots(pred_name, options):
    image_files = [os.path.join(options.directory, x)
        for x in sorted([y for y in os.listdir(options.directory)
                if y.split('.')[-1].lower() == 'jpg'],
            key=lambda x: int(x.split('.')[0]))]
    first = options.first-1 if options.first is not None else 0
    image_results = Results(pred_name).image_results[first:]
    top_results = [x.detections[0]for x in image_results]
    return [Plot(image_files[i],
        [x.centre[0] for x in top_results[i].rectangles],
        [x.centre[1] for x in top_results[i].rectangles],
        markers[len(top_results[i].rectangles)] if len(top_results[i].rectangles) in markers else None,
        colours[len(top_results[i].rectangles)] if len(top_results[i].rectangles) in colours else None)
        for i in range(len(top_results))
        if i < len(image_files)]

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
        for i in range(len(self.plots[self.curr_pos].x)):
            self.ax.scatter([self.plots[self.curr_pos].x[i]],
                [self.plots[self.curr_pos].y[i]],
                marker=self.plots[self.curr_pos].markers[i],
                color=self.plots[self.curr_pos].colours[i])
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
            for i in range(len(self.plots[self.curr_pos].x)):
                self.ax.scatter([self.plots[self.curr_pos].x[i]],
                    [self.plots[self.curr_pos].y[i]],
                    marker=self.plots[self.curr_pos].markers[i],
                    color=self.plots[self.curr_pos].colours[i])
            self.fig.canvas.draw()

def main():
    parser = argparse.ArgumentParser(
        description='Visualises bee labels and predictions.')
    parser.add_argument('data_format', type=str, help='input file format',
        choices=sorted(format_functions.keys()))
    parser.add_argument('file_name', type=str, help='input file name')
    parser.add_argument("-d", "--directory", type=str,
                    help="images directory")
    parser.add_argument("-f", "--first", type=int,
                    help="index of first image to show")
    args = parser.parse_args()

    plots = format_functions[args.data_format](args.file_name, args)
    controller = PltController(plots)

if __name__ == '__main__':
    main()
