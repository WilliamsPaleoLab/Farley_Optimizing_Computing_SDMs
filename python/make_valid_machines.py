__author__ = 'scottsfarley'
import numpy as np
def isEven(num):
    if num == 1:
        return True
    if num % 2 == 0:
        return True
    else:
        return False

def isValidMemPerCore(mem, cores):
    avg = mem / float(cores)
    if avg >= 0.9 and avg <= 6.5:
        return True
    else:
        return False

def isMultiple(mem):
    if mem % 0.25 == 0:
        return True
    else:
        return False


validTypes = []
cores = range(1, 33)
mem = np.arange(0, 208, 0.25)
for coreConfig in cores:
    for memConfig in mem:
        if isEven(coreConfig) and isValidMemPerCore(memConfig, coreConfig) and isMultiple(memConfig):
            rate = (coreConfig * 0.01002) + (memConfig * 0.00156)
            cost = rate * 3
            config = (coreConfig, memConfig, cost)
            validTypes.append(config)


v = np.array(validTypes)
result = []
costCap = 700
cumCost = 0
i = 0
for t in validTypes:
    cpu = t[0]
    mem = t[1]
    cost = t[2]
    if mem % 2 == 0:
        cumCost += cost
        i += 1

print cumCost
print i








# predefinedTypes = [(1, 3.75), (2, 7.5), (4, 15), (8, 30), (16, 60), (32, 120), (2, 13), (4, 26), (8, 52), (16, 104), (32, 208),
#     (2, 1.8), (4, 3.6), (8, 7.2), (16, 14.4),(32, 28.8)]
#
# outfile = open("/Users/scottsfarley/documents/thesis-scripts/data/review/valid_GCE_types.csv", 'w')
# import csv
# writer = csv.writer(outfile)
# writer.writerow(['Cores', 'GBMemory', "Cost", "ConfigurationType"])
# for config in validTypes:
#     s = [config[0], config[1], config[2],  "Custom"]
#     writer.writerow(s)
# for config in predefinedTypes:
#     s = [config[0], config[1], 0,  "Predefined"]
#     writer.writerow(s)
