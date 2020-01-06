import glob
import numpy as np

for dataset in ['/hurricane-100x500x500', 'miranda-256x384x384', 'qmcpack6k-34500x69x69', 'qmcpack8h-816x115x69x69']:
    for filepath in glob.glob('/home/kazhao/data/{:}/*'.format(dataset)):
        filename = filepath.split('/')[-1]

        data = np.fromfile(filepath, dtype=np.float32)
        r1 = int(dataset.split('-')[-1].split('x')[0])
        r2 = int(dataset.split('-')[-1].split('x')[1])
        r3 = int(dataset.split('-')[-1].split('x')[2])
        data = data.reshape([r1, r2, r3])
        shape = "%d %d %d" % (r1, r2, r3)
        r1 = r1 // 8 * 8
        r2 = r2 // 8 * 8
        r3 = r3 // 8 * 8
        data = data[:r1, :r2, :r3]
        print('{:} {:} from {:} to {:}'.format(dataset, filename, shape, "%d %d %d" % (r1, r2, r3)))
        data.tofile("/lcrc/project/ECP-EZ/public/compression/datasets/0/{}_truncated.bin.dat".format(filename.split('.')[0]))
        # print("/lcrc/project/ECP-EZ/public/compression/datasets/0/{}_truncated.bin.dat".format(filename.split('.')[0]))
