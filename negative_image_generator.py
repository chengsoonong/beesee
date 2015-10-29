import json
from math import sqrt
from PIL import Image

part_names = ['thorax', 'abdomen', 'right wing', 'left antenna', 'left wing',
    'right antenna', 'head']

def average_axis_excluding_none(items, axis):
    return (sum(i[axis] if i is not None else 0.0 for i in items)
        / sum(1 if i is not None else 0.0 for i in items))

def max_deviation_excluding_none(items, average):
    x_av, y_av = average
    return max(sqrt((i[0]-x_av)**2+(i[1]-y_av)**2) if i is not None else 0.0
        for i in items)

def main():
    with open('labels.json') as f:
        json_data = json.load(f)['labelled']
    saves_counter = 0
    for l in json_data:
        parts = [l[n] for n in part_names]
        if None in parts and any(p is not None for p in parts):
            x, y = (average_axis_excluding_none(parts, a) for a in (0, 1))
            w, h = l['size']
            y = h - y # change coordinate system
            d = max_deviation_excluding_none(parts, (x, y)) * 1.1

            # left, upper, right, lower
            bxs = [[0,   0, x-d, y-d], [x-d,   0, x+d, y-d], [x+d, 0,   w, y-d],
                   [0, y-d, x-d, y+d],                       [x+d, y-d, w, y+d],
                   [0, y+d, x-d,   h], [x-d, y+d, x+d,   h], [x+d, y+d, w, h]]
            for b in bxs:
                b[0] = int(max(0, min(w, b[0])))
                b[1] = int(max(0, min(h, b[1])))
                b[2] = int(max(0, min(w, b[2])))
                b[3] = int(max(0, min(h, b[3])))

            complete_boxes = [b for b in bxs
                if b[2]-b[0] >= 16 and b[3]-b[1] >= 16]

            img = Image.open(l['path'])
            for c in complete_boxes:
                cropped = img.crop(c)

                saves_counter += 1
                cropped.save('/Users/jakubnabaglo/neg/{}.jpg'.format(saves_counter), 'JPEG')

if __name__ == '__main__':
    main()