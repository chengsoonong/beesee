import random
import json
import scipy.io
import shutil
import os
import numpy as np

random.seed(2)

all_features = ['head', 'thorax', 'abdomen', 'left wing', 'right wing',
    'left antenna', 'right antenna']
features = ['head', 'thorax', 'abdomen', 'left wing', 'right wing',
    'left antenna', 'right antenna']

def complete(label):
    return all(label[p] is not None for p in all_features)

def transform_coords(coords, size):
    return (coords[0], size[1]-coords[1])

def episode_to_mat_dict(episode):
    array = np.empty([len(features), 2, len(episode)])
    for e in range(len(episode)):
        e_dict = episode[e]
        for f in range(len(features)):
            coords = transform_coords(e_dict[features[f]], e_dict['size'])
            array[f,0,e] = coords[0]
            array[f,1,e] = coords[1]
    return {'labels': array}


def main():
    with open('labels.json', 'r') as f:
        all_labels = json.load(f)['labelled']
        for l in all_labels:
            if 'difficult' not in l:
                l['difficult'] = False
        labels = [x for x in all_labels if not x['difficult'] and complete(x)]
        random.shuffle(labels)
        labels = labels[0:300]

        try:
            os.makedirs("labels")
        except OSError:
            pass

        try:
            os.makedirs("json_labels")
        except OSError:
            pass

        for e in range(1, 6):
            try:
                os.makedirs("images/set{}".format(e))
            except OSError:
                pass
            episode = labels[(e-1)*50:e*50]
            mat_dict = episode_to_mat_dict(episode)
            scipy.io.savemat('labels/set{}.mat'.format(e), mat_dict)
            for i in range(len(episode)):
                shutil.copy(episode[i]['path'],
                    'images/set{}/{}.jpg'.format(e, i+1))
            with open('json_labels/set{}.json', 'w') as f:
                json.dump(episode, f)

if __name__ == '__main__':
    main()
