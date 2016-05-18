__author__ = 'scottsfarley'

##creates a configuration file with all the settings needed to setup and connect to the database

conf = {}
conf['conf'] = {}
conf['conf']['path'] = '/Users/scottsfarley/documents/thesis-scripts/conf/test.conf'


conf['database'] = {} ##settins to connect to the results database
conf['database']['host'] = "localhost"
conf['database']['user'] = "farley"
conf['database']['pass'] = "G0Bears7!"
conf['database']['db'] = "SDM_Stopwatch"

conf['model'] = {} ## settings for dismo.gbmstep function
conf['model']['tree_complexity'] = 10
conf['model']['learning_rate'] = 0.01
conf['model']['bag_fraction'] = 0.8
conf['model']['family'] = 'Bernoulli'
conf['model']['step_size'] = 10
conf['model']['n_folds'] = 10

conf['file_system'] = {}
# conf['file_system']['base_path'] = "/Users/scottsfarley/documents/thesis-scripts/data/"
# conf['file_system']['pred_loc'] = "/Users/scottsfarley/documents/thesis-scripts/data/predictors.tif" ## location of multiband predictor variables
# conf['file_system']['Quercus'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
# conf['file_system']['Betula'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
# conf['file_system']['Picea'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
# conf['file_system']['Tsuga'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences

conf['file_system']['base_path'] = "C:/Users/willlab/Documents/Scott/thesis-scripts/data/"
conf['file_system']['pred_loc'] = "C:/Users/willlab/Documents/Scott/thesis-scripts/data/predictors/standard_biovars/.tif" ## location of multiband predictor variables
conf
conf['file_system']['Quercus'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
conf['file_system']['Betula'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
conf['file_system']['Picea'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences
conf['file_system']['Tsuga'] = "/Users/scottsfarley/documents/thesis-scripts/data/sequoia_bioclim.csv" ##location of pre-thresholded csv of occurrences


conf['file_system']['log_loc'] = "/Users/scottsfarley/documents/thesis-scripts/logs/sdm.log" ## for logging messages

conf['logging'] = {}
conf['logging']['current_level'] = "DEBUG"


conf['experiments'] = {}
conf['experiments']['n_point_options'] = [5, 10, 50, 100, 500]
conf['experiments']['core_options'] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
conf['experiments']['memory_options'] = [1, 2, 4, 8, 16, 24]
conf['experiments']['spatial_resolution_options'] = [0.5, 0.25, 0.1]
conf['experiments']['num_reps'] = 10
conf['experiments']['species_options'] = ['Quercus', 'Picea', "Betula", 'Tsuga']

conf['deviceID'] = -1




print "Writing configuration file to disk."
##commit to the disk
import pyyaml

with open(conf['conf']['path'], 'w') as ymlfile:
    cfg = pyyaml.dump(conf, ymlfile)

print "Configuration file generation successful."

