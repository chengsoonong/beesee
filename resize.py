import json
from PIL import Image

parts = ["thorax", "abdomen", "right wing", "left antenna", "head", "right antenna", "left wing"]

def resize_coordinates(coordinates, original_size, new_size):
    return ([coordinates[i]/original_size[i]*new_size[i] for i in range(2)]
        if coordinates is not None
        else None)

def main():
    with open('labels.json') as f:
        labels = json.load(f)
    for i in labels['labelled']:
        old_size = i['size']
        if old_size[0] > 427:
            image = Image.open(i['path'])
            image.thumbnail((427,285), Image.ANTIALIAS)
            image.save(i['path'], "JPEG")
            new_size = list(image.size)

            i['size'] = new_size
            for p in parts:
                i[p] = resize_coordinates(i[p], old_size, new_size)
    with open('labels.json', 'w') as f:
        json.dump(labels,f)

if __name__ == '__main__':
    main()